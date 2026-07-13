#!/usr/bin/env bash
# Portable smoke checks for bash/zsh (invoked as: bash|zsh scripts/ci-smoke.sh GVM_DEST)
set -e
GVM_DEST="${1:?GVM_DEST required}"
# shellcheck disable=SC1090
source "$GVM_DEST/gvm/scripts/gvm"
echo "GVM_VERSION=${GVM_VERSION:-} HEXDUMP_PATH=${HEXDUMP_PATH:-}"
test -n "$GVM_VERSION"
test -n "$HEXDUMP_PATH"
gvm install go1.22.12 -B
gvm use go1.22.12
go version | grep -E 'go1\.22\.12'
gvm list --porcelain | grep -F 'go1.22.12'
spaced="$GVM_DEST/dir with spaces"
mkdir -p "$spaced"
cd "$spaced"
pwd | grep 'dir with spaces'
echo SMOKE_OK
