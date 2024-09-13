SHELL := /bin/bash
VERSION := $(shell cat VERSION)
ROOT_DIR := /opt

URL_MIPSEL := https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-lsb/nfqws
URL_MIPS := https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-msb/nfqws
URL_AARCH64 := https://raw.githubusercontent.com/bol-van/zapret/master/binaries/aarch64/nfqws
URL_ARMV7 := https://raw.githubusercontent.com/bol-van/zapret/master/binaries/arm/nfqws

.DEFAULT_GOAL := packages

_clean:
	rm -rf out/$(BUILD_DIR)
	mkdir -p out/$(BUILD_DIR)/control
	mkdir -p out/$(BUILD_DIR)/data

_conffiles:
	echo "$(ROOT_DIR)/etc/nfqws/nfqws.conf" > out/$(BUILD_DIR)/control/conffiles
	echo "$(ROOT_DIR)/etc/nfqws/user.list" >> out/$(BUILD_DIR)/control/conffiles
	echo "$(ROOT_DIR)/etc/nfqws/auto.list" >> out/$(BUILD_DIR)/control/conffiles
	echo "$(ROOT_DIR)/etc/nfqws/exclude.list" >> out/$(BUILD_DIR)/control/conffiles

_control:
	echo "Package: nfqws-keenetic" > out/$(BUILD_DIR)/control/control
	echo "Version: $(VERSION)" >> out/$(BUILD_DIR)/control/control

	@if [[ "$(BUILD_DIR)" == "openwrt" ]]; then \
		echo "Depends: iptables, iptables-mod-extra, iptables-mod-nfqueue, iptables-mod-filter, iptables-mod-ipopt, iptables-mod-conntrack-extra, ip6tables, ip6tables-mod-nat, ip6tables-extra" >> out/$(BUILD_DIR)/control/control; \
	else \
		echo "Depends: iptables" >> out/$(BUILD_DIR)/control/control; \
	fi

	echo "License: MIT" >> out/$(BUILD_DIR)/control/control
	echo "Section: net" >> out/$(BUILD_DIR)/control/control
	echo "URL: https://github.com/Anonym-tsk/nfqws-keenetic" >> out/$(BUILD_DIR)/control/control
	echo "Architecture: $(ARCH)" >> out/$(BUILD_DIR)/control/control
	echo "Description:  NFQWS service" >> out/$(BUILD_DIR)/control/control

_scripts:
	cp common/ipk/common out/$(BUILD_DIR)/control/common
	cp common/ipk/preinst out/$(BUILD_DIR)/control/preinst
	cp common/ipk/postrm out/$(BUILD_DIR)/control/postrm

	@if [[ "$(BUILD_DIR)" == "all" ]]; then \
		cp common/ipk/postinst-multi out/$(BUILD_DIR)/control/postinst; \
	elif [[ "$(BUILD_DIR)" == "openwrt" ]]; then \
	  cp common/ipk/postinst-openwrt out/$(BUILD_DIR)/control/postinst; \
	else \
		cp common/ipk/postinst out/$(BUILD_DIR)/control/postinst; \
	fi

	@if [[ "$(BUILD_DIR)" == "openwrt" ]]; then \
		cp common/ipk/prerm-openwrt out/$(BUILD_DIR)/control/prerm; \
		cp common/ipk/env-openwrt out/$(BUILD_DIR)/control/env; \
	else \
		cp common/ipk/prerm out/$(BUILD_DIR)/control/prerm; \
		cp common/ipk/env out/$(BUILD_DIR)/control/env; \
	fi

_binary:
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/usr/bin
	curl -sSL $(URL) -o out/$(BUILD_DIR)/data$(ROOT_DIR)/usr/bin/nfqws
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/usr/bin/nfqws

_binary-multi:
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/usr/bin
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary

	curl -sSL $(URL_MIPSEL) -o out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mipsel
	curl -sSL $(URL_MIPS) -o out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mips
	curl -sSL $(URL_AARCH64) -o out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-aarch64
	curl -sSL $(URL_ARMV7) -o out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-armv7

	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mipsel
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mips
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-aarch64
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-armv7

_startup:
	@if [[ "$(BUILD_DIR)" == "openwrt" ]]; then \
  		cat etc/init.d/openwrt-start etc/init.d/common etc/init.d/openwrt-end > out/$(BUILD_DIR)/data$(ROOT_DIR)/etc/init.d/nfqws-keenetic; \
  		chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/etc/init.d/nfqws-keenetic; \
	else \
	  	cat etc/init.d/entware-start etc/init.d/common etc/init.d/entware-end > out/$(BUILD_DIR)/data$(ROOT_DIR)/etc/init.d/S51nfqws; \
	  	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/etc/init.d/S51nfqws; \
	fi

_ipk:
	make _clean

	# control.tar.gz
	make _conffiles
	make _control
	make _scripts
	cd out/$(BUILD_DIR)/control; tar czvf ../control.tar.gz .; cd ../../..

	# data.tar.gz
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/var/log
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/var/run
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/etc/init.d


	cp -r etc/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/etc/nfqws
	make _startup

	@if [[ "$(BUILD_DIR)" != "openwrt" ]]; then \
		cp -r etc/ndm out/$(BUILD_DIR)/data$(ROOT_DIR)/etc/ndm; \
	fi

	@if [[ "$(BUILD_DIR)" == "all" ]] || [[ "$(BUILD_DIR)" == "openwrt" ]]; then \
		make _binary-multi; \
	else \
		make _binary; \
	fi

	cd out/$(BUILD_DIR)/data; tar czvf ../data.tar.gz .; cd ../../..

	# ipk
	echo 2.0 > out/$(BUILD_DIR)/debian-binary
	cd out/$(BUILD_DIR); \
	tar czvf ../$(FILENAME) control.tar.gz data.tar.gz debian-binary; \
	cd ../..

mipsel:
	@make \
		BUILD_DIR=mipsel \
		ARCH=mipsel-3.4 \
		FILENAME=nfqws-keenetic_$(VERSION)_mipsel-3.4.ipk \
		URL="$(URL_MIPSEL)" \
		_ipk

mips:
	@make \
		BUILD_DIR=mips \
		ARCH=mips-3.4 \
		FILENAME=nfqws-keenetic_$(VERSION)_mips-3.4.ipk \
		URL="$(URL_MIPS)" \
		_ipk

aarch64:
	@make \
		BUILD_DIR=aarch64 \
		ARCH=aarch64-3.10 \
		FILENAME=nfqws-keenetic_$(VERSION)_aarch64-3.10.ipk \
		URL="$(URL_AARCH64)" \
		_ipk

armv7:
	@make \
		BUILD_DIR=armv7 \
		ARCH=armv7-3.2 \
		FILENAME=nfqws-keenetic_$(VERSION)_armv7-3.2.ipk \
		URL="$(URL_ARMV7)" \
		_ipk

multi:
	@make \
		BUILD_DIR=all \
		ARCH=all \
		FILENAME=nfqws-keenetic_$(VERSION)_all_entware.ipk \
		_ipk

openwrt:
	@make \
		BUILD_DIR=openwrt \
		ARCH=all \
		FILENAME=nfqws-keenetic_$(VERSION)_all_openwrt.ipk \
		ROOT_DIR= \
		_ipk

packages: mipsel mips aarch64 armv7 multi openwrt

_repo-clean:
	rm -rf out/_pages/$(BUILD_DIR)
	mkdir -p out/_pages/$(BUILD_DIR)

_repo-html:
	echo '<html><head><title>nfqws-keenetic opkg repository</title></head><body>' > out/_pages/$(BUILD_DIR)/index.html
	echo '<h1>Index of /$(BUILD_DIR)/</h1><hr>' >> out/_pages/$(BUILD_DIR)/index.html
	echo '<pre>' >> out/_pages/$(BUILD_DIR)/index.html
	echo '<a href="../">../</a>' >> out/_pages/$(BUILD_DIR)/index.html
	echo '<a href="$(FILENAME)">$(FILENAME)</a>' >> out/_pages/$(BUILD_DIR)/index.html
	echo '</pre>' >> out/_pages/$(BUILD_DIR)/index.html
	echo '<hr></body></html>' >> out/_pages/$(BUILD_DIR)/index.html

_repo-index:
	echo '<html><head><title>nfqws-keenetic opkg repository</title></head><body>' > out/_pages/index.html
	echo '<h1>Index of /</h1><hr>' >> out/_pages/index.html
	echo '<pre>' >> out/_pages/index.html
	echo '<a href="all/">all/</a>' >> out/_pages/index.html
	echo '<a href="aarch64/">aarch64/</a>' >> out/_pages/index.html
	echo '<a href="armv7/">armv7/</a>' >> out/_pages/index.html
	echo '<a href="mips/">mips/</a>' >> out/_pages/index.html
	echo '<a href="mipsel/">mipsel/</a>' >> out/_pages/index.html
	echo '<a href="openwrt/">openwrt/</a>' >> out/_pages/index.html
	echo '</pre>' >> out/_pages/index.html
	echo '<hr></body></html>' >> out/_pages/index.html

_repository:
	make _repo-clean

	cp "out/$(FILENAME)" "out/_pages/$(BUILD_DIR)/"

	echo "Package: nfqws-keenetic" > out/_pages/$(BUILD_DIR)/Packages
	echo "Version: $(VERSION)" >> out/_pages/$(BUILD_DIR)/Packages

	@if [[ "$(BUILD_DIR)" == "openwrt" ]]; then \
		echo "Depends: iptables, iptables-mod-extra, iptables-mod-nfqueue, iptables-mod-filter, iptables-mod-ipopt, iptables-mod-conntrack-extra, ip6tables, ip6tables-mod-nat, ip6tables-extra" >> out/_pages/$(BUILD_DIR)/Packages; \
	else \
		echo "Depends: iptables" >> out/_pages/$(BUILD_DIR)/Packages; \
	fi

	echo "Section: net" >> out/_pages/$(BUILD_DIR)/Packages
	echo "Architecture: $(ARCH)" >> out/_pages/$(BUILD_DIR)/Packages
	echo "Filename: $(FILENAME)" >> out/_pages/$(BUILD_DIR)/Packages
	echo "Size: $(shell wc -c out/$(FILENAME) | awk '{print $$1}')" >> out/_pages/$(BUILD_DIR)/Packages
	echo "SHA256sum: $(shell sha256sum out/$(FILENAME) | awk '{print $$1}')" >> out/_pages/$(BUILD_DIR)/Packages
	echo "Description:  NFQWS service" >> out/_pages/$(BUILD_DIR)/Packages

	gzip -k out/_pages/$(BUILD_DIR)/Packages

	@make _repo-html

repo-mipsel:
	@make \
		BUILD_DIR=mipsel \
		ARCH=mipsel-3.4 \
		FILENAME=nfqws-keenetic_$(VERSION)_mipsel-3.4.ipk \
		_repository

repo-mips:
	@make \
		BUILD_DIR=mips \
		ARCH=mips-3.4 \
		FILENAME=nfqws-keenetic_$(VERSION)_mips-3.4.ipk \
		_repository

repo-aarch64:
	@make \
		BUILD_DIR=aarch64 \
		ARCH=aarch64-3.10 \
		FILENAME=nfqws-keenetic_$(VERSION)_aarch64-3.10.ipk \
		_repository

repo-armv7:
	@make \
		BUILD_DIR=armv7 \
		ARCH=armv7-3.2 \
		FILENAME=nfqws-keenetic_$(VERSION)_armv7-3.2.ipk \
		_repository

repo-multi:
	@make \
		BUILD_DIR=all \
		ARCH=all \
		FILENAME=nfqws-keenetic_$(VERSION)_all_entware.ipk \
		_repository

repo-openwrt:
	@make \
		BUILD_DIR=openwrt \
		ARCH=all \
		FILENAME=nfqws-keenetic_$(VERSION)_all_openwrt.ipk \
		_repository

repository: repo-mipsel repo-mips repo-aarch64 repo-armv7 repo-multi repo-openwrt _repo-index

clean:
	rm -rf out/mipsel
	rm -rf out/mips
	rm -rf out/aarch64
	rm -rf out/armv7
	rm -rf out/all
	rm -rf out/openwrt
