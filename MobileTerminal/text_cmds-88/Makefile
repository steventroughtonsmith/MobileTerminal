
CC=xcrun clang

COMMONFLAGS=-arch armv7 -arch arm64 -Wimplicit -Wl,-segalign,4000 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -miphoneos-version-min=9.0 -O3 -I./include
LFLAGS=$(COMMONFLAGS)
CFLAGS=$(COMMONFLAGS) -w -c

SIGNING_IDENTITY="iPhone Developer: Steven Troughton-Smith (GF23LK2QK8)"

CAT_OBJS=cat/cat.o
CAT_LIBS=

all: pre cat sign
 
cat: $(CAT_OBJS)
	$(CC) $(LFLAGS) $(CAT_OBJS) $(CAT_LIBS) -o ../bin/$@

pre:
	mkdir -p ../bin/

sign:
	export CODESIGN_ALLOCATE=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/../bin/codesign_allocate
	xcrun codesign -f -s $(SIGNING_IDENTITY) --preserve-metadata=identifier,entitlements --timestamp=none ../bin/cat
 

%.o:%.c
	$(CC) $(CFLAGS) $< -o $@ 

clean:
	rm -rf */*.o
	rm -rf ../bin/cat