
CC=xcrun clang

COMMONFLAGS=-arch armv7 -arch arm64 -Wimplicit -Wl,-segalign,4000 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -miphoneos-version-min=9.0 -O3 -I./include
LFLAGS=$(COMMONFLAGS)
CFLAGS=$(COMMONFLAGS) -w -c

SIGNING_IDENTITY="iPhone Developer: Steven Troughton-Smith (GF23LK2QK8)"

PING_OBJS=ping.tproj/ping.o
PING_LIBS=

TRACEROUTE_OBJS=traceroute.tproj/traceroute.o traceroute.tproj/findsaddr-socket.o traceroute.tproj/ifaddrlist.o traceroute.tproj/as.o traceroute.tproj/version.o
TRACEROUTE_LIBS=

IFCONFIG_OBJS=ifconfig.tproj/ifconfig.o ifconfig.tproj/af_inet6.o ifconfig.tproj/ifbridge.o ifconfig.tproj/af_inet.o ifconfig.tproj/af_link.o ifconfig.tproj/ifclone.o ifconfig.tproj/ifvlan.o ifconfig.tproj/ifmedia.o ifconfig.tproj/ifbond.o
IFCONFIG_LIBS=

NETSTAT_OBJS=netstat.tproj/inet.o netstat.tproj/main.o netstat.tproj/systm.o netstat.tproj/inet6.o netstat.tproj/if.o netstat.tproj/mptcp.o netstat.tproj/mbuf.o netstat.tproj/ipsec.o netstat.tproj/unix.o netstat.tproj/route.o netstat.tproj/mcast.o netstat.tproj/data.o netstat.tproj/tp_astring.o
NETSTAT_LIBS=


all: pre ping sign
 
ping: $(PING_OBJS)
	$(CC) $(LFLAGS) $(PING_OBJS) $(PING_LIBS) -o ../bin/$@

traceroute: $(TRACEROUTE_OBJS)
	$(CC) $(LFLAGS) $(TRACEROUTE_OBJS) $(TRACEROUTE_LIBS) -o ../bin/$@

ifconfig: $(IFCONFIG_OBJS)
	$(CC) $(LFLAGS) $(IFCONFIG_OBJS) $(IFCONFIG_LIBS) -o ../bin/$@

netstat: $(NETSTAT_OBJS)
	$(CC) $(LFLAGS) $(NETSTAT_OBJS) $(NETSTAT_LIBS) -o ../bin/$@

pre:
	mkdir -p ../bin/

sign:
	export CODESIGN_ALLOCATE=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/../bin/codesign_allocate
	xcrun codesign -f -s $(SIGNING_IDENTITY) --preserve-metadata=identifier,entitlements --timestamp=none ../bin/ping
 

%.o:%.c
	$(CC) $(CFLAGS) $< -o $@ 

clean:
	rm -rf */*.o
	rm -rf ../bin/ping ../bin/traceroute ../bin/ifconfig ../bin/netstat