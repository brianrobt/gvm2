---
title: Fix global pkgset env duplication - Plan
type: fix
date: 2026-07-18
artifact_contract: ce-unified-plan/v1
artifact_readiness: implementation-ready
product_contract_source: ce-plan-bootstrap
execution: code
origin: https://github.com/brianrobt/gvm2/issues/8
---

# Fix global pkgset env duplication - Plan

## Goal Capsule

Stop writing duplicated `GOPATH` / `PATH` prefixes into `*@global` environment files.
`pkgset-create` is the source of truth; the installer mirrors the clean behavior.
Done when new `global` pkgset files have a single global path prefix and a regression test covers both paths.

## Product Contract

### Summary

Base Go environment files already embed the `global` pkgset. Copying that file to `$go@global` and appending global prefixes again doubles PATH/GOPATH. Fix creation so `@global` is a clean copy for the global case.

### Problem Frame

When a Go version is installed, `scripts/install` `create_enviroment` writes `environments/$GO_NAME` with `gvm_pkgset_name=global` and global `GOPATH`/`PATH` already set, then calls `gvm pkgset create global`. That command copies the base file to `$GO_NAME@global` and appends the same global prefixes again.

The installer does the same for system Go: write `environments/system` with global baked in, copy to `system@global`, then append again (with an explicit `@TODO`).

Duplicate entries are usually harmless but pollute env files and confuse PATH debugging.

### Requirements

- R1. `gvm pkgset create global` must not prepend a second copy of the global pkgset `GOPATH`/`PATH` when the base env already includes them.
- R2. Fresh installer `system@global` must match the clean shape (copy of `system`, no redundant append block).
- R3. Non-`global` pkgsets keep current behavior (copy base, then prepend named pkgset paths and overlays).
- R4. Existing installs are not migrated; only newly created env files are fixed.

### Scope Boundaries

- In scope: `scripts/pkgset-create`, `binscripts/gvm-installer`, regression coverage.
- Out of scope: rewriting already-installed `@global` files; #9 nil-hash TODOs; P3 features.

### Acceptance Examples

- AE1. After `gvm pkgset create global` on a base env that already has global paths, `$go@global` contains one `pkgsets/$go/global` GOPATH assignment chain without `global:…:global`.
- AE2. After installer with an existing system Go, `system@global` equals `system` (or differs only by harmless metadata), with no second GOPATH/PATH append block.

## Planning Contract

### Key Technical Decisions

- KTD1. Special-case `global` in `pkgset-create`: after copying the base env, skip the GOPATH/PATH (and redundant `gvm_pkgset_name`) appends. Overlay block already skips `global`.
- KTD2. Installer: `cp system system@global` only; delete the `@TODO` append block.
- KTD3. Do not try to detect "already has global" via string parsing of env files — the product invariant is that base envs always embed global (`create_enviroment` / installer). Name-based special case matches that invariant and the existing `!= global` overlay gate.
- KTD4. No migration of existing user env files in this change.

### Assumptions

- Base environment files for every Go version always embed the global pkgset before `@global` is created (true for current `install` and installer paths).

## Implementation Units

### U1. Fix `pkgset-create` for global

**Goal:** Creating the `global` pkgset no longer doubles PATH/GOPATH.
**Requirements:** R1, R3
**Dependencies:** none
**Files:** `scripts/pkgset-create`, `tests/gvm_pkgset_global_comment_test.sh` (new)
**Approach:** When `target_set_name` is `global`, copy the base environment to `$go@global` and stop (dirs still created as today). For all other names, keep the current append + overlay behavior.
**Execution note:** Prefer a lightweight `tf` comment test that can assert env-file shape after a controlled `pkgset create global`, or a small shell helper under tests if comment-test setup is too heavy.
**Test scenarios:**
- Happy path: with a fake/minimal `GVM_ROOT` whose base env already has global GOPATH/PATH, `pkgset create global` yields `@global` without a second `GOPATH="…/global:$GOPATH"` line.
- Edge: non-global pkgset still gets prepended GOPATH/PATH and overlay block.
- Error: creating an already-existing pkgset still fatals.
**Verification:** New test passes; manual inspection of generated `@global` shows no duplicate prefix.

### U2. Align installer `system@global`

**Goal:** Installer no longer copies the buggy append shape.
**Requirements:** R2
**Dependencies:** U1 (behaviorally aligned; can land in same commit)
**Files:** `binscripts/gvm-installer`
**Approach:** Keep directory creation and `system` env write; `cp` to `system@global`; remove append + `@TODO`.
**Test scenarios:**
- Happy path: after installer with `GOROOT`/system Go present, `system@global` has no trailing duplicate GOPATH/PATH exports beyond what `system` already contains.
**Verification:** Diff `system` vs `system@global` is empty (or only intentional), smoke/CI install still succeeds.

## Verification Contract

- Run the new pkgset global regression test via the existing `tf` suite path (or equivalent local invocation).
- Smoke: installer completes; `gvm pkgset create` for a non-global name still works if exercised.
- No ChangeLog bump required unless shipping a release note in the same PR (optional one-liner under Fixed for next version).

## Definition of Done

- U1 and U2 landed; `@TODO` removed from installer.
- Regression test covers the global duplication case.
- Issue #8 addressed (close manually if bot lacks permission).
