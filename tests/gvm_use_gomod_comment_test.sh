source $GVM_ROOT/scripts/gvm

## Requires go1.22.12 from 00gvm_install_comment_test.sh
mkdir -p /tmp/gvm2-mod-detect-$$/subdir
echo 'module example.com/t

go 1.22
' > /tmp/gvm2-mod-detect-$$/go.mod
cd /tmp/gvm2-mod-detect-$$/subdir
gvm use # status=0; match=/Now using version go1\.22\./
go version # status=0; match=/go1\.22\./
cd /
rm -rf /tmp/gvm2-mod-detect-$$
