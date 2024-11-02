_web-clean:
	rm -rf out/$(BUILD_DIR)
	mkdir -p out/$(BUILD_DIR)/control
	mkdir -p out/$(BUILD_DIR)/data

_web-control:
	echo "Package: nfqws-keenetic-web" > out/$(BUILD_DIR)/control/control
	echo "Version: $(VERSION)" >> out/$(BUILD_DIR)/control/control
	echo "Depends: nfqws-keenetic, php8-cgi, php8-mod-session, lighttpd, lighttpd-mod-cgi, lighttpd-mod-setenv, lighttpd-mod-rewrite, lighttpd-mod-redirect" >> out/$(BUILD_DIR)/control/control
	echo "License: MIT" >> out/$(BUILD_DIR)/control/control
	echo "Section: net" >> out/$(BUILD_DIR)/control/control
	echo "URL: https://github.com/Anonym-tsk/nfqws-keenetic" >> out/$(BUILD_DIR)/control/control
	echo "Architecture: all" >> out/$(BUILD_DIR)/control/control
	echo "Description:  NFQWS service web interface" >> out/$(BUILD_DIR)/control/control
	echo "" >> out/$(BUILD_DIR)/control/control

_web-scripts:
	@if [[ "$(BUILD_DIR)" == "web-openwrt" ]]; then \
	  cp web/ipk/postinst-openwrt out/$(BUILD_DIR)/control/postinst; \
	else \
		cp web/ipk/postinst out/$(BUILD_DIR)/control/postinst; \
	fi

_web-ipk:
	make _web-clean

	# control.tar.gz
	make _web-control
	make _web-scripts
	cd out/$(BUILD_DIR)/control; tar czvf ../control.tar.gz .; cd ../../..

	# data.tar.gz
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)
	@if [[ "$(BUILD_DIR)" == "web-openwrt" ]]; then \
		cp -r web/share/www out/$(BUILD_DIR)/data$(ROOT_DIR)/www; \
		sed -i -E "s#__VERSION__#v$(VERSION)#g" out/$(BUILD_DIR)/data$(ROOT_DIR)/www/nfqws/index.html; \
	else \
		cp -r web/share out/$(BUILD_DIR)/data$(ROOT_DIR)/share; \
		sed -i -E "s#__VERSION__#v$(VERSION)#g" out/$(BUILD_DIR)/data$(ROOT_DIR)/share/www/nfqws/index.html; \
	fi

	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)/etc/lighttpd/conf.d
	@if [[ "$(BUILD_DIR)" == "web-openwrt" ]]; then \
		cp web/etc/lighttpd/conf.d/openwrt.conf out/$(BUILD_DIR)/data$(ROOT_DIR)/etc/lighttpd/conf.d/80-nfqws.conf; \
	else \
		cp web/etc/lighttpd/conf.d/entware.conf out/$(BUILD_DIR)/data$(ROOT_DIR)/etc/lighttpd/conf.d/80-nfqws.conf; \
	fi

	cd out/$(BUILD_DIR)/data; tar czvf ../data.tar.gz .; cd ../../..

	# ipk
	echo 2.0 > out/$(BUILD_DIR)/debian-binary
	cd out/$(BUILD_DIR); \
	tar czvf ../$(FILENAME) control.tar.gz data.tar.gz debian-binary; \
	cd ../..

web-entware:
	@make \
		BUILD_DIR=web \
		FILENAME=nfqws-keenetic-web_$(VERSION)_all_entware.ipk \
		_web-ipk

web-openwrt:
	@make \
		BUILD_DIR=web-openwrt \
		FILENAME=nfqws-keenetic-web_$(VERSION)_all_openwrt.ipk \
		ROOT_DIR= \
		_web-ipk

web-interface: web-entware web-openwrt
