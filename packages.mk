_clean:
	rm -rf out/$(BUILD_DIR)
	mkdir -p out/$(BUILD_DIR)/control
	mkdir -p out/$(BUILD_DIR)/data

_download_bins: TARGET_URL=$(shell curl -s 'https://api.github.com/repos/bol-van/zapret/releases/latest' | grep 'browser_download_url' | grep 'embedded.tar.gz' | cut -d '"' -f 4)
_download_bins:
	rm -f out/zapret.tar.gz
	rm -rf out/zapret
	mkdir -p out/zapret
	curl -sSL $(TARGET_URL) -o out/zapret.tar.gz
	tar -C out/zapret -xzf "out/zapret.tar.gz"
	cd out/zapret/*/; mv binaries/ ../; cd ..

_conffiles:
	cp common/ipk/conffiles out/$(BUILD_DIR)/control/conffiles
	@if [[ "$(BUILD_DIR)" == "openwrt" ]]; then \
		sed -i -E "s#/opt/#/#g" out/$(BUILD_DIR)/control/conffiles; \
	fi

_control:
	echo "Package: nfqws-keenetic" > out/$(BUILD_DIR)/control/control
	echo "Version: $(VERSION)" >> out/$(BUILD_DIR)/control/control
	echo "Depends: iptables, busybox" >> out/$(BUILD_DIR)/control/control
	echo "Conflicts: tpws-keenetic" >> out/$(BUILD_DIR)/control/control
	echo "License: MIT" >> out/$(BUILD_DIR)/control/control
	echo "Section: net" >> out/$(BUILD_DIR)/control/control
	echo "URL: https://github.com/Anonym-tsk/nfqws-keenetic" >> out/$(BUILD_DIR)/control/control
	echo "Architecture: $(ARCH)" >> out/$(BUILD_DIR)/control/control
	echo "Description:  NFQWS service" >> out/$(BUILD_DIR)/control/control
	echo "" >> out/$(BUILD_DIR)/control/control

_scripts: CONFIG_VERSION=$(shell grep -E '^CONFIG_VERSION=' etc/nfqws/nfqws.conf 2>/dev/null | grep -oE '[0-9]+$$')
_scripts:
	cp common/ipk/preinst out/$(BUILD_DIR)/control/preinst
	sed -i -E "s#^CURRENT_VERSION=([0-9]+)#CURRENT_VERSION=$(CONFIG_VERSION)#" out/$(BUILD_DIR)/control/preinst

	cp common/ipk/postinst out/$(BUILD_DIR)/control/postinst
	cp common/ipk/prerm out/$(BUILD_DIR)/control/prerm
	cp common/ipk/postrm out/$(BUILD_DIR)/control/postrm

	@if [[ "$(BUILD_DIR)" == "openwrt" ]]; then \
		sed -i -E "s#/opt/#/#g" out/$(BUILD_DIR)/control/preinst; \
		sed -i -E "s#/opt/#/#g" out/$(BUILD_DIR)/control/postinst; \
		sed -i -E "s#/opt/#/#g" out/$(BUILD_DIR)/control/prerm; \
		sed -i -E "s#/opt/#/#g" out/$(BUILD_DIR)/control/postrm; \
	fi

_binary:
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/usr/bin
	cp out/zapret/binaries/$(BIN)/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/usr/bin/nfqws
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/usr/bin/nfqws

_binary-multi:
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/usr/bin
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary

	cp out/zapret/binaries/linux-mipsel/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mipsel
	cp out/zapret/binaries/linux-mips/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mips
	cp out/zapret/binaries/linux-mips64/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mips64
	cp out/zapret/binaries/linux-arm64/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-aarch64
	cp out/zapret/binaries/linux-arm/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-armv7
	cp out/zapret/binaries/linux-x86/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-x86
	cp out/zapret/binaries/linux-x86_64/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-x86_64
	cp out/zapret/binaries/linux-lexra/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-lexra

	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mipsel
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mips
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-mips64
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-aarch64
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-armv7
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-x86
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-x86_64
	chmod +x out/$(BUILD_DIR)/data$(ROOT_DIR)/tmp/nfqws_binary/nfqws-lexra

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

_apk:
	make _clean

	make _conffiles
	make _scripts

	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/var/log
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/var/run
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/etc/init.d

	cp -r etc/nfqws out/$(BUILD_DIR)/data$(ROOT_DIR)/etc/nfqws
	sed -i -E "s#/opt/#/#g" out/$(BUILD_DIR)/data$(ROOT_DIR)/etc/nfqws/nfqws.conf
	make _startup
	make _binary-multi

mipsel: _download_bins
	@make \
		BUILD_DIR=mipsel \
		ARCH=mipsel-3.4 \
		FILENAME=nfqws-keenetic_$(VERSION)_mipsel-3.4.ipk \
		BIN=linux-mipsel \
		_ipk

mips: _download_bins
	@make \
		BUILD_DIR=mips \
		ARCH=mips-3.4 \
		FILENAME=nfqws-keenetic_$(VERSION)_mips-3.4.ipk \
		BIN=linux-mips \
		_ipk

aarch64: _download_bins
	@make \
		BUILD_DIR=aarch64 \
		ARCH=aarch64-3.10 \
		FILENAME=nfqws-keenetic_$(VERSION)_aarch64-3.10.ipk \
		BIN=linux-arm64 \
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
		ROOT_DIR= \
		_apk

entware: mipsel mips aarch64 multi
