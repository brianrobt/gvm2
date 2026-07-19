#!/usr/bin/env bash
# Portable smoke checks for bash/zsh (invoked as: bash|zsh scripts/ci-smoke.sh GVM_DEST)
set -e
GVM_DEST="${1:?GVM_DEST required}"
# shellcheck disable=SC1090
source "$GVM_DEST/gvm/scripts/gvm"
echo "GVM_VERSION=${GVM_VERSION:-} HEXDUMP_PATH=${HEXDUMP_PATH:-}"
test -n "$GVM_VERSION"
test -n "$HEXDUMP_PATH"
# system@global is only created when an existing Go was detected at install time
if [ -f "$GVM_DEST/gvm/environments/system@global" ]; then
  if grep -q 'global:$GOPATH' "$GVM_DEST/gvm/environments/system@global"; then
    echo "FAIL: system@global has duplicated global GOPATH prefix" >&2
    exit 1
  fi
  diff -q "$GVM_DEST/gvm/environments/system" "$GVM_DEST/gvm/environments/system@global"
fi
gvm install go1.22.12 -B
gvm use go1.22.12
go version | grep -E 'go1\.22\.12'
gvm list --porcelain | grep -F 'go1.22.12'
# install creates $go@global via pkgset create; must not duplicate global GOPATH
if grep -q 'global:$GOPATH' "$GVM_DEST/gvm/environments/go1.22.12@global"; then
  echo "FAIL: go1.22.12@global has duplicated global GOPATH prefix" >&2
  exit 1
fi
spaced="$GVM_DEST/dir with spaces"
mkdir -p "$spaced"
cd "$spaced"
pwd | grep 'dir with spaces'
echo SMOKE_OK
