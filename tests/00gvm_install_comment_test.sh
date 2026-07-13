## Cleanup test objects
gvm uninstall go1.22.12 > /dev/null 2>&1
gvm uninstall go1.21.13 > /dev/null 2>&1
#######################

gvm install go1.22.12 -B #status=0
gvm install go1.21.13 -B #status=0
gvm list #status=0; match=/go1.22.12/
gvm use go1.22.12 #status=0
gvm list --porcelain #status=0; match=/go1.22.12/
