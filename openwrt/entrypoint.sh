#!/bin/sh

./setup.sh

echo "src-link nfqws /builder/src/openwrt" > feeds.conf

./scripts/feeds update nfqws
./scripts/feeds install -a -p nfqws

make defconfig
make CONFIG_USE_APK=y package/nfqws-keenetic/compile V=s
make CONFIG_USE_APK=y package/index V=s
make CONFIG_USE_APK= package/nfqws-keenetic/compile V=s
make CONFIG_USE_APK= package/index V=s
