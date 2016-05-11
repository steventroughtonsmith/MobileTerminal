
CC=xcrun clang

COMMONFLAGS=-arch armv7 -arch arm64 -Wimplicit -Wl,-segalign,4000 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -miphoneos-version-min=9.0 -O3 -I./include
LFLAGS=$(COMMONFLAGS)
CFLAGS=$(COMMONFLAGS) -w -c

SIGNING_IDENTITY="iPhone Developer: Steven Troughton-Smith (GF23LK2QK8)"

PS_OBJS= ps/ps.o ps/keyword.o ps/print.o ps/tasks.o ps/nlist.o ps/fmt.o
PS_LIBS=-lutil -lcurses


all: pre ps sign
 
ps: $(PS_OBJS)
	$(CC) $(LFLAGS) $(PS_OBJS) $(PS_LIBS) -o ../bin/$@

pre:
	mkdir -p ../bin/

sign:
	export CODESIGN_ALLOCATE=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/../bin/codesign_allocate
	xcrun codesign -f -s $(SIGNING_IDENTITY) --preserve-metadata=identifier,entitlements --timestamp=none ../bin/ps
 

%.o:%.c
	$(CC) $(CFLAGS) $< -o $@ 

clean:
	rm -rf */*.o
	rm -rf ../bin/ps