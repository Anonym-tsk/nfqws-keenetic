_web-clean:
	rm -rf out/$(BUILD_DIR)
	mkdir -p out/$(BUILD_DIR)/control
	mkdir -p out/$(BUILD_DIR)/data

_web-conffiles:
	echo "$(ROOT_DIR)/share/www/index.html" > out/$(BUILD_DIR)/control/conffiles

_web-control:
	echo "Package: nfqws-keenetic-web" > out/$(BUILD_DIR)/control/control
	echo "Version: $(VERSION)" >> out/$(BUILD_DIR)/control/control
	echo "Depends: nfqws-keenetic, php8-cgi, uhttpd_kn" >> out/$(BUILD_DIR)/control/control
	echo "Conflicts: uhttpd" >> out/$(BUILD_DIR)/control/control
	echo "License: MIT" >> out/$(BUILD_DIR)/control/control
	echo "Section: net" >> out/$(BUILD_DIR)/control/control
	echo "URL: https://github.com/Anonym-tsk/nfqws-keenetic" >> out/$(BUILD_DIR)/control/control
	echo "Architecture: all" >> out/$(BUILD_DIR)/control/control
	echo "Description:  NFQWS service web interface (Keenetic only)" >> out/$(BUILD_DIR)/control/control
	echo "" >> out/$(BUILD_DIR)/control/control

_web-scripts:
	cp web/ipk/postrm out/$(BUILD_DIR)/control/postrm
	cp web/ipk/postinst out/$(BUILD_DIR)/control/postinst

_web-ipk:
	make _web-clean

	# control.tar.gz
	make _web-conffiles
	make _web-control
	make _web-scripts
	cd out/$(BUILD_DIR)/control; tar czvf ../control.tar.gz .; cd ../../..

	# data.tar.gz
	mkdir -p out/$(BUILD_DIR)/data$(ROOT_DIR)
	cp -r web/share out/$(BUILD_DIR)/data$(ROOT_DIR)/share
	sed -i -E "s#__VERSION__#v$(VERSION)#g" out/$(BUILD_DIR)/data$(ROOT_DIR)/share/www/nfqws/index.html
	cd out/$(BUILD_DIR)/data; tar czvf ../data.tar.gz .; cd ../../..

	# ipk
	echo 2.0 > out/$(BUILD_DIR)/debian-binary
	cd out/$(BUILD_DIR); \
	tar czvf ../$(FILENAME) control.tar.gz data.tar.gz debian-binary; \
	cd ../..

web-interface:
	@make \
		BUILD_DIR=web \
		FILENAME=nfqws-keenetic-web_$(VERSION)_all_entware.ipk \
		_web-ipk
