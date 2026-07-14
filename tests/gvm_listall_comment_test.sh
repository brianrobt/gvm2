gvm listall #status=0
gvm listall --latest #status=0; match=/go1\./
gvm listall --porcelain #status=0; match=/go1/
gvm listall -h #status=0; match=/--latest/
