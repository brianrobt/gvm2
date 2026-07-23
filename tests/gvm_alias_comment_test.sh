source $GVM_ROOT/scripts/gvm

## Cleanup test objects (may not exist yet — ignore errors)
gvm alias delete foo > /dev/null 2>&1
gvm alias delete bar > /dev/null 2>&1
#######################

gvm alias # status=0
gvm alias create foo go1.22.12 # status=0
gvm alias create bar go1.21.13 # status=0
gvm alias list # status=0; match=/gvm go aliases/; match=/foo \(go1\.22\.12\)/; match=/bar \(go1\.21\.13\)/
gvm use foo # status=0
go version # status=0; match=/go1\.22\.12/
gvm use bar # status=0
go version # status=0; match=/go1\.21\.13/
gvm alias delete foo
gvm alias list # status=0; match=/gvm go aliases/; match!=/foo \(go1\.22\.12\)/; match=/bar \(go1\.21\.13\)/
gvm alias delete bar
gvm alias list # status=0; match=/gvm go aliases/; match!=/foo \(go1\.22\.12\)/; match!=/bar \(go1\.21\.13\)/
