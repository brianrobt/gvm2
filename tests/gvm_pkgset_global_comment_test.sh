source $GVM_ROOT/scripts/gvm

## Synthetic Go env whose base file already embeds the global pkgset.
## Note: tf runs each line as its own command — never use multi-line heredocs.
mkdir -p "$GVM_ROOT/gos/duptest" "$GVM_ROOT/pkgsets/duptest" "$GVM_ROOT/environments"
printf '%s\n' 'export GVM_ROOT; GVM_ROOT="'"$GVM_ROOT"'"' 'export gvm_go_name; gvm_go_name="duptest"' 'export gvm_pkgset_name; gvm_pkgset_name="global"' 'export GOPATH; GOPATH="'"$GVM_ROOT"'/pkgsets/duptest/global"' 'export PATH; PATH="'"$GVM_ROOT"'/pkgsets/duptest/global/bin:$PATH"' > "$GVM_ROOT/environments/duptest"

gvm_go_name=duptest "$GVM_ROOT/scripts/pkgset-create" global # status=0
test -f "$GVM_ROOT/environments/duptest@global" # status=0
## @global should be a clean copy — no GOPATH="…/global:$GOPATH" append
grep 'global:$GOPATH' "$GVM_ROOT/environments/duptest@global" # status=1
diff -q "$GVM_ROOT/environments/duptest" "$GVM_ROOT/environments/duptest@global" # status=0

## Non-global pkgsets still prepend paths
gvm_go_name=duptest "$GVM_ROOT/scripts/pkgset-create" myset # status=0
grep 'pkgsets/duptest/myset:$GOPATH' "$GVM_ROOT/environments/duptest@myset" # status=0
grep 'Package Set-Specific Overrides' "$GVM_ROOT/environments/duptest@myset" # status=0

## Cleanup
rm -rf "$GVM_ROOT/gos/duptest" "$GVM_ROOT/pkgsets/duptest" "$GVM_ROOT/environments/duptest" "$GVM_ROOT/environments/duptest@global" "$GVM_ROOT/environments/duptest@myset"
