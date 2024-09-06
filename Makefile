VERSION := $(shell cat VERSION)

URL_MIPSEL := "https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-lsb/nfqws"
URL_MIPS := "https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-msb/nfqws"
URL_AARCH64 := "https://raw.githubusercontent.com/bol-van/zapret/master/binaries/aarch64/nfqws"
URL_ARMV7 := "https://raw.githubusercontent.com/bol-van/zapret/master/binaries/arm/nfqws"

.DEFAULT_GOAL := all

_clean:
	rm -rf out/$(ARCH)
	mkdir -p out/$(ARCH)/control
	mkdir -p out/$(ARCH)/data

_conffiles:
	echo "/opt/etc/nfqws/nfqws.conf" > out/$(ARCH)/control/conffiles
	echo "/opt/etc/nfqws/user.list" >> out/$(ARCH)/control/conffiles
	echo "/opt/etc/nfqws/auto.list" >> out/$(ARCH)/control/conffiles
	echo "/opt/etc/nfqws/exclude.list" >> out/$(ARCH)/control/conffiles

_control:
	echo "Package: nfqws-keenetic" > out/$(ARCH)/control/control
	echo "Version: $(VERSION)" >> out/$(ARCH)/control/control
	echo "Depends: busybox, iptables" >> out/$(ARCH)/control/control
	echo "License: MIT" >> out/$(ARCH)/control/control
	echo "Section: net" >> out/$(ARCH)/control/control
	echo "URL: https://github.com/Anonym-tsk/nfqws-keenetic" >> out/$(ARCH)/control/control
	echo "Architecture: $(ARCH)" >> out/$(ARCH)/control/control
	echo "Description: NFQWS service" >> out/$(ARCH)/control/control

_scripts:
	cp common/ipk/preinst out/$(ARCH)/control/preinst
	cp common/ipk/postinst out/$(ARCH)/control/postinst
	cp common/ipk/prerm out/$(ARCH)/control/prerm
	cp common/ipk/postrm out/$(ARCH)/control/postrm

_debian-binary:
	echo 2.0 > out/$(ARCH)/debian-binary

_binary-arch:
	mkdir -p out/$(ARCH)/data/opt/usr/bin
	curl -sSL $(URL) -o out/$(ARCH)/data/opt/usr/bin/nfqws
	chmod +x out/$(ARCH)/data/opt/usr/bin/nfqws

_binary-all:
	mkdir -p out/$(ARCH)/data/opt/usr/bin
	mkdir -p out/$(ARCH)/data/tmp/nfqws

	curl -sSL "$(URL_MIPSEL)" -o out/$(ARCH)/data/tmp/nfqws/nfqws-mipsel
	curl -sSL "$(URL_MIPS)" -o out/$(ARCH)/data/tmp/nfqws/nfqws-mips
	curl -sSL "$(URL_AARCH64)" -o out/$(ARCH)/data/tmp/nfqws/nfqws-aarch64
	curl -sSL "$(URL_ARMV7)" -o out/$(ARCH)/data/tmp/nfqws/nfqws-armv7

	chmod +x out/$(ARCH)/data/tmp/nfqws/nfqws-mipsel
	chmod +x out/$(ARCH)/data/tmp/nfqws/nfqws-mips
	chmod +x out/$(ARCH)/data/tmp/nfqws/nfqws-aarch64
	chmod +x out/$(ARCH)/data/tmp/nfqws/nfqws-armv7

_start:
	# cleanup
	make _clean

	# control.tar.gz
	make _conffiles
	make _control
	make _scripts
	cd out/$(ARCH)/control; tar czvf ../control.tar.gz .; cd ../../..

_end:
	# data.tar.gz
	cp -r etc out/$(ARCH)/data/opt/etc
	cd out/$(ARCH)/data; tar czvf ../data.tar.gz .; cd ../../..

	# ipk
	make _debian-binary
	cd out/$(ARCH); tar czvf ../nfqws-keenetic_$(VERSION)_$(ARCH).ipk control.tar.gz data.tar.gz debian-binary; cd ../..

_ipk-arch:
	make _start
	make _binary-arch
	make _end

_ipk-multi:
	make _start
	make _binary-all
	make _end

mipsel:
	make ARCH=mipsel-3.4 URL="$(URL_MIPSEL)" _ipk-arch

mips:
	make ARCH=mips-3.4 URL="$(URL_MIPS)" _ipk-arch

aarch64:
	make ARCH=aarch64-3.10 URL="$(URL_AARCH64)" _ipk-arch

armv7:
	make ARCH=armv7-3.2 URL="$(URL_ARMV7)" _ipk-arch

multi:
	make ARCH=all _ipk-multi

all: mipsel mips aarch64 armv7 multi

clean:
	rm -rf out/mipsel
	rm -rf out/mips
	rm -rf out/aarch64
	rm -rf out/armv7
