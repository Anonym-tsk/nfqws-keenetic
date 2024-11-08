_clean:
	rm -rf out/$(BUILD_DIR)
	mkdir -p out/$(BUILD_DIR)/control
	mkdir -p out/$(BUILD_DIR)/data

_download_bins: TARGET_URL=$(shell curl 'https://api.github.com/repos/bol-van/zapret/releases?per_page=1' | jq -r '.[].assets[].browser_download_url | select(. | endswith("tar.gz"))')
_download_bins:
	rm -f out/zapret.tar.gz
	rm -rf out/zapret
	curl -sSL $(TARGET_URL) -o out/zapret.tar.gz
	mkdir -p out/zapret
	tar -C out/zapret -xzf "out/zapret.tar.gz"
	cd out/zapret/*/; mv binaries/ ../; cd ..

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
	cp out/zapret/binaries/$(BIN)/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/usr/bin/nfqws
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/usr/bin/nfqws

_binary-multi:
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/usr/bin
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary

	cp out/zapret/binaries/mips32r1-lsb/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mipsel
	cp out/zapret/binaries/mips32r1-msb/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mips
	cp out/zapret/binaries/aarch64/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-aarch64
	cp out/zapret/binaries/arm/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-armv7
	cp out/zapret/binaries/x86/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-x86
	cp out/zapret/binaries/x86_64/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-x86_64

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

mipsel: _download_bins
	@make \
		BUILD_DIR=mipsel \
		ARCH=mipsel-3.4 \
		FILENAME=nfqws-keenetic_$(VERSION)_mipsel-3.4.ipk \
		BIN=mips32r1-lsb \
		_ipk

mips: _download_bins
	@make \
		BUILD_DIR=mips \
		ARCH=mips-3.4 \
		FILENAME=nfqws-keenetic_$(VERSION)_mips-3.4.ipk \
		BIN=mips32r1-msb \
		_ipk

aarch64: _download_bins
	@make \
		BUILD_DIR=aarch64 \
		ARCH=aarch64-3.10 \
		FILENAME=nfqws-keenetic_$(VERSION)_aarch64-3.10.ipk \
		BIN=aarch64 \
		_ipk

multi: _download_bins
	@make \
		BUILD_DIR=all \
		ARCH=all \
		FILENAME=nfqws-keenetic_$(VERSION)_all_entware.ipk \
		_ipk

openwrt: _download_bins
	@make \
		BUILD_DIR=openwrt \
		ARCH=all \
		FILENAME=nfqws-keenetic_$(VERSION)_all_openwrt.ipk \
		ROOT_DIR= \
		_ipk

packages: mipsel mips aarch64 multi openwrt
