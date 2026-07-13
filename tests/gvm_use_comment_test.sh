source $GVM_ROOT/scripts/gvm
gvm use go1.22.12 # status=0
go version # status=0; match=/go1\.22\.12/
gvm use go1.21.13 # status=0
go version # status=0; match=/go1\.21\.13/
