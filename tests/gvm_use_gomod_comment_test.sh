source "$GVM_ROOT/scripts/gvm"

## Requires go1.22.12 from 00gvm_install_comment_test.sh
## Note: tf runs each line as its own command — never use multi-line quotes/heredocs.
MODDIR=$(mktemp -d "${TMPDIR:-/tmp}/gvm2-mod-detect.XXXXXX")
mkdir -p "$MODDIR/subdir"
printf '%s\n' 'module example.com/t' '' 'go 1.22' > "$MODDIR/go.mod"
cd "$MODDIR/subdir" # status=0
gvm use # status=0; match=/Now using version go1\.22\./
go version # status=0; match=/go1\.22\./
cd /
[[ -n "$MODDIR" && "$MODDIR" == "${TMPDIR:-/tmp}"* ]] && rm -rf "$MODDIR"
