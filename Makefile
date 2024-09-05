VERSION := $(shell cat VERSION)

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
	echo "Architecture: $(ARCH)-$(KERNEL)" >> out/$(ARCH)/control/control
	echo "Description: NFQWS service" >> out/$(ARCH)/control/control

_scripts:
	cp common/ipk/preinst out/$(ARCH)/control/preinst
	cp common/ipk/postinst out/$(ARCH)/control/postinst
	cp common/ipk/prerm out/$(ARCH)/control/prerm
	cp common/ipk/postrm out/$(ARCH)/control/postrm

_debian-binary:
	echo 2.0 > out/$(ARCH)/debian-binary

_binary:
	mkdir -p out/$(ARCH)/data/opt/usr/bin
	curl -sSL $(URL) -o out/$(ARCH)/data/opt/usr/bin/nfqws
	chmod +x out/$(ARCH)/data/opt/usr/bin/nfqws

_ipk:
	# cleanup
	make _clean

	# control.tar.gz
	make _conffiles
	make _control
	make _scripts
	cd out/$(ARCH)/control; tar czvf ../control.tar.gz .; cd ../../..

	# data.tar.gz
	make _binary
	cp -r etc out/$(ARCH)/data/opt/etc
	cd out/$(ARCH)/data; tar czvf ../data.tar.gz .; cd ../../..

	# ipk
	make _debian-binary
	#ar -r out/nfqws-keenetic_$(VERSION)_$(ARCH)-3.10.ipk out/$(ARCH)/control.tar.gz out/$(ARCH)/data.tar.gz out/$(ARCH)/debian-binary
	cd out/$(ARCH); tar czvf ../nfqws-keenetic_$(VERSION)_$(ARCH)-$(KERNEL).ipk control.tar.gz data.tar.gz debian-binary; cd ../..

mipsel:
	make ARCH=mipsel KERNEL=3.4 URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-lsb/nfqws" _ipk

mips:
	make ARCH=mips KERNEL=3.4 URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-msb/nfqws" _ipk

aarch64:
	make ARCH=aarch64 KERNEL=3.10 URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/aarch64/nfqws" _ipk

armv7:
	make ARCH=armv7 KERNEL=3.2 URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/arm/nfqws" _ipk

all: mipsel mips aarch64 armv7

clean:
	rm -rf out/mipsel
	rm -rf out/mips
	rm -rf out/aarch64
	rm -rf out/armv7
