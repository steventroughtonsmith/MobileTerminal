MobileTerminal
=============

Proof-of-concept for sandboxed Terminal environment for iOS. Uses dlopen() to load mach binaries as libraries, then finds & calls main(). Does not require a jailbreak. Will only work in 32-bit mode.

To compile, replace SIGNING_IDENTITY in each subproject's Makefile with your own signing identity.

#Included Tools
Includes the following BSD utilities from Darwin:

| | | | | | |
| --- | --- | --- | --- | --- | --- |
| cat | cp | ipcrm | mknod | rm | unlink |
| chflags | dd | ipcs | mtree | rmdir | zcat |
| chgrp | df | link | mv | stat | zopen |
| chmod | du | ln | pathchk | sum |
| chown | gunzip | ls | ping | symlink |
| cksum | gzip | mkdir | ps | touch |
| compress | install | mkfifo | readlink | uncompress |


SCREENSHOT
=============

[![](http://hccdata.s3.amazonaws.com/gh_mobileterm_1.jpg)](http://hccdata.s3.amazonaws.com/gh_mobileterm_1.jpg)
