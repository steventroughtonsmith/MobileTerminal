
CC=xcrun clang

COMMONFLAGS=-arch armv7 -arch arm64 -Wimplicit -Wl,-segalign,4000 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -miphoneos-version-min=9.0 -O3 -I./include -DNO_PACK_SUPPORT -DNO_XZ_SUPPORT -DGZIP_APPLE_VERSION="\"251\"" -DNO_BZIP2_SUPPORT
LFLAGS=$(COMMONFLAGS)
CFLAGS=$(COMMONFLAGS) -w -c

SIGNING_IDENTITY="iPhone Developer: Steven Troughton-Smith (GF23LK2QK8)"

LS_OBJS= ls/ls.o ls/print.o ls/cmp.o ls/util.o
LS_LIBS=-lutil -lcurses

CP_OBJS= cp/cp.o cp/utils.o
CP_LIBS=

MKDIR_OBJS=mkdir/mkdir.o
MKDIR_LIBS=

RM_OBJS=rm/rm.o
RM_LIBS=

MV_OBJS=mv/mv.o
MV_LIBS=

DD_OBJS=dd/args.o dd/conv_tab.o dd/conv.o dd/dd.o dd/misc.o dd/position.o
DD_LIBS=

LN_OBJS=ln/ln.o
LN_LIBS=

GZIP_OBJS=gzip/gzip.o #  gzip/zuncompress.o gzip/unpack.o  gzip/unbzip2.o gzip/unxz.o 
GZIP_LIBS=-lz

DF_OBJS=df/df.o df/vfslist.o
DF_LIBS=-lutil

CHMOD_OBJS=chmod/chmod.o chmod/chmod_acl.o
CHMOD_LIBS=

CHOWN_OBJS=chown/chown.o
CHOWN_LIBS=

CHFLAGS_OBJS=chflags/chflags.o
CHFLAGS_LIBS=

TOUCH_OBJS=touch/touch.o
TOUCH_LIBS=

CKSUM_OBJS=cksum/cksum.o cksum/crc.o cksum/crc32.o cksum/sum1.o cksum/sum2.o cksum/print.o
CKSUM_LIBS=

RMDIR_OBJS=rmdir/rmdir.o
RMDIR_LIBS=

DU_OBJS=du/du.o
DU_LIBS=

STAT_OBJS=stat/stat.o
STAT_LIBS=

PATHCHK_OBJS=pathchk/pathchk.o
PATHCHK_LIBS=

MKNOD_OBJS=mknod/mknod.o
MKNOD_LIBS=

IPCS_OBJS=ipcs/ipcs.o
IPCS_LIBS=

IPCRM_OBJS=ipcrm/ipcrm.o
IPCRM_LIBS=

INSTALL_OBJS=install/xinstall.o
INSTALL_LIBS=

COMPRESS_OBJS=compress/compress.o compress/zopen.o
COMPRESS_LIBS=

MKFIFO_OBJS=mkfifo/mkfifo.o
MKFIFO_LIBS=

MTREE_OBJS=mtree/mtree.o mtree/compare.o mtree/create.o mtree/spec.o mtree/specspec.o mtree/verify.o mtree/misc.o mtree/excludes.o cksum/crc.o
MTREE_LIBS=

all: pre ls cp mkdir rm unlink mv dd ln link symlink gzip gunzip df chmod chown chgrp chflags touch cksum sum rmdir du stat readlink pathchk mknod ipcs ipcrm install compress uncompress zopen zcat mkfifo mtree sign
 
ls: $(LS_OBJS)
	$(CC) $(LFLAGS) $(LS_OBJS) $(LS_LIBS) -o ../bin/$@

cp: $(CP_OBJS)
	$(CC) $(LFLAGS) $(CP_OBJS) $(CP_LIBS) -o ../bin/$@

mkdir: $(MKDIR_OBJS)
	$(CC) $(LFLAGS) $(MKDIR_OBJS) $(MKDIR_LIBS) -o ../bin/$@

rm unlink: $(RM_OBJS)
	$(CC) $(LFLAGS) $(RM_OBJS) $(RM_LIBS) -o ../bin/$@

mv: $(MV_OBJS)
	$(CC) $(LFLAGS) $(MV_OBJS) $(MV_LIBS) -o ../bin/$@

dd: $(DD_OBJS)
	$(CC) $(LFLAGS) $(DD_OBJS) $(DD_LIBS) -o ../bin/$@

ln link symlink: $(LN_OBJS)
	$(CC) $(LFLAGS) $(LN_OBJS) $(LN_LIBS) -o ../bin/$@

gzip gunzip: $(GZIP_OBJS)
	$(CC) $(LFLAGS) $(GZIP_OBJS) $(GZIP_LIBS) -o ../bin/$@

df: $(DF_OBJS)
	$(CC) $(LFLAGS) $(DF_OBJS) $(DF_LIBS) -o ../bin/$@

chmod: $(CHMOD_OBJS)
	$(CC) $(LFLAGS) $(CHMOD_OBJS) $(CHMOD_LIBS) -o ../bin/$@

chown chgrp: $(CHOWN_OBJS)
	$(CC) $(LFLAGS) $(CHOWN_OBJS) $(CHOWN_LIBS) -o ../bin/$@

chflags: $(CHFLAGS_OBJS)
	$(CC) $(LFLAGS) $(CHFLAGS_OBJS) $(CHFLAGS_LIBS) -o ../bin/$@

touch: $(TOUCH_OBJS)
	$(CC) $(LFLAGS) $(TOUCH_OBJS) $(TOUCH_LIBS) -o ../bin/$@

cksum sum: $(CKSUM_OBJS)
	$(CC) $(LFLAGS) $(CKSUM_OBJS) $(CKSUM_LIBS) -o ../bin/$@

rmdir: $(RMDIR_OBJS)
	$(CC) $(LFLAGS) $(RMDIR_OBJS) $(RMDIR_LIBS) -o ../bin/$@

du: $(DU_OBJS)
	$(CC) $(LFLAGS) $(DU_OBJS) $(DU_LIBS) -o ../bin/$@

stat readlink: $(STAT_OBJS)
	$(CC) $(LFLAGS) $(STAT_OBJS) $(STAT_LIBS) -o ../bin/$@

pathchk: $(PATHCHK_OBJS)
	$(CC) $(LFLAGS) $(PATHCHK_OBJS) $(PATHCHK_LIBS) -o ../bin/$@

mknod: $(MKNOD_OBJS)
	$(CC) $(LFLAGS) $(MKNOD_OBJS) $(MKNOD_LIBS) -o ../bin/$@

ipcs: $(IPCS_OBJS)
	$(CC) $(LFLAGS) $(IPCS_OBJS) $(IPCS_LIBS) -o ../bin/$@

ipcrm: $(IPCRM_OBJS)
	$(CC) $(LFLAGS) $(IPCRM_OBJS) $(IPCRM_LIBS) -o ../bin/$@

install: $(INSTALL_OBJS)
	$(CC) $(LFLAGS) $(INSTALL_OBJS) $(INSTALL_LIBS) -o ../bin/$@

compress zopen uncompress zcat: $(COMPRESS_OBJS)
	$(CC) $(LFLAGS) $(COMPRESS_OBJS) $(COMPRESS_LIBS) -o ../bin/$@

mkfifo: $(MKFIFO_OBJS)
	$(CC) $(LFLAGS) $(MKFIFO_OBJS) $(MKFIFO_LIBS) -o ../bin/$@

mtree: $(MTREE_OBJS)
	$(CC) $(LFLAGS) $(MTREE_OBJS) $(MTREE_LIBS) -o ../bin/$@


pre:
	mkdir -p build

sign:
	export CODESIGN_ALLOCATE=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/../bin/codesign_allocate
	xcrun codesign -f -s $(SIGNING_IDENTITY) --preserve-metadata=identifier,entitlements --timestamp=none ../bin/ls ../bin/cp ../bin/mkdir ../bin/rm ../bin/unlink ../bin/mv ../bin/dd ../bin/ln ../bin/link ../bin/symlink ../bin/gzip ../bin/gunzip ../bin/df ../bin/chmod ../bin/chown ../bin/chgrp ../bin/chflags ../bin/touch ../bin/cksum ../bin/sum ../bin/rmdir ../bin/du ../bin/stat ../bin/readlink ../bin/pathchk ../bin/mknod ../bin/ipcs ../bin/ipcrm ../bin/install ../bin/compress ../bin/uncompress ../bin/zopen ../bin/zcat ../bin/mkfifo ../bin/mtree
 

%.o:%.c
	$(CC) $(CFLAGS) $< -o $@ 

clean:
	rm -rf */*.o
	rm -rf ../bin/ls ../bin/cp ../bin/mkdir ../bin/rm ../bin/unlink ../bin/mv ../bin/dd ../bin/ln ../bin/link ../bin/symlink ../bin/gzip ../bin/gunzip ../bin/df ../bin/chmod ../bin/chown ../bin/chgrp ../bin/chflags ../bin/touch ../bin/cksum ../bin/sum ../bin/rmdir ../bin/du ../bin/stat ../bin/readlink ../bin/pathchk ../bin/mknod ../bin/ipcs ../bin/ipcrm ../bin/install ../bin/compress ../bin/uncompress ../bin/zopen ../bin/zcat ../bin/mkfifo ../bin/mtree