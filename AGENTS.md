# gvm2 agent guide

Community reboot of [moovweb/gvm](https://github.com/moovweb/gvm). CLI command stays `gvm`; install dir stays `~/.gvm` for drop-in compatibility. Repo/product name is **gvm2**.

## Layout

| Path | Role |
|------|------|
| `binscripts/gvm-installer` | Curl / CI installer (clones into `~/.gvm`) |
| `scripts/` | Commands (`install`, `list`, …) and helpers under `function/` / `env/` |
| `scripts/env/cd` | Shell `cd` override for `.go-version` / `.go-pkgset` auto-switch |
| `tests/` | `tf` comment tests; `tests/scenario/` are isolated installs |

## Commands

```bash
# Local install into a temp dir (same shape as CI)
./binscripts/gvm-installer "$(git rev-parse --abbrev-ref HEAD)" /tmp/gvm2-test

# Run suite (requires Ruby gem `tf`)
gem install tf -v '>=0.4.1'
rake default          # comment tests
rake scenario         # scenario installs
```

Smoke after sourcing:

```bash
source /tmp/gvm2-test/gvm/scripts/gvm
gvm install go1.22.12 -B
gvm use go1.22.12
mkdir -p "/tmp/dir with spaces" && cd "/tmp/dir with spaces"
```

Set `GVM_NO_CD=1` before sourcing to skip the `cd` hook (performance / autofs).

## Issue triage labels

| Label | Use |
|-------|-----|
| `p0-shell` | `cd`, PATH, zsh / hexdump |
| `p1-bootstrap` | Install / bootstrap without existing Go |
| `p2-docs` | Docs / UX |
| `upstream-pr` | Tracking a moovweb/gvm PR |
| `wontfix` | Out of scope for gvm2 |

## Conventions

- Conventional Commits; no AI co-author trailers.
- Prefer binary install (`-B` / auto prefer-binary) over documenting go1.4 chains.
- Do not rename the `gvm` CLI or `~/.gvm` path without an explicit migration plan.
