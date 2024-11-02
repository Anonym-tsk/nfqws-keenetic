URL_MIPSEL := https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-lsb/nfqws
URL_MIPS := https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-msb/nfqws
URL_AARCH64 := https://raw.githubusercontent.com/bol-van/zapret/master/binaries/aarch64/nfqws
URL_ARMV7 := https://raw.githubusercontent.com/bol-van/zapret/master/binaries/arm/nfqws
URL_X86 := https://raw.githubusercontent.com/bol-van/zapret/master/binaries/x86/nfqws
URL_X86_64 := https://raw.githubusercontent.com/bol-van/zapret/master/binaries/x86_64/nfqws

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
		echo "Depends: iptables, busybox" >> out/$(BUILD_DIR)/control/control; \
	fi

	echo "Conflicts: tpws-keenetic" >> out/$(BUILD_DIR)/control/control
	echo "License: MIT" >> out/$(BUILD_DIR)/control/control
	echo "Section: net" >> out/$(BUILD_DIR)/control/control
	echo "URL: https://github.com/Anonym-tsk/nfqws-keenetic" >> out/$(BUILD_DIR)/control/control
	echo "Architecture: $(ARCH)" >> out/$(BUILD_DIR)/control/control
	echo "Description:  NFQWS service" >> out/$(BUILD_DIR)/control/control
	echo "" >> out/$(BUILD_DIR)/control/control

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
	curl -sSL $(URL_X86) -o out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-x86
	curl -sSL $(URL_X86_64) -o out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-x86_64

	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mipsel
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mips
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-aarch64
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-armv7
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-x86
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-x86_64

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

packages: mipsel mips aarch64 multi openwrt
