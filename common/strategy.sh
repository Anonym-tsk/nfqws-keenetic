#!/bin/sh

if [ -f "/opt/etc/init.d/S51nfqws" ]; then
    ROOT_DIR=/opt
    /opt/etc/init.d/S51nfqws stop
else
    ROOT_DIR=
    /etc/init.d/nfqws-keenetic stop
fi

mkdir -p "$ROOT_DIR/tmp/nfqws-keenetic/strategy/zapret"
cd "$ROOT_DIR/tmp/nfqws-keenetic/strategy"

RELEASE_URL=`curl -s https://api.github.com/repos/bol-van/zapret/releases/latest | grep browser_download_url | grep '.tar.gz' | cut -d '"' -f 4`
curl -SL# $RELEASE_URL -o zapret.tar.gz
tar -C zapret -xzf zapret.tar.gz
cd zapret/*/

./install_bin.sh
SECURE_DNS=1 FWTYPE=iptables SKIP_TPWS=1 ./blockcheck.sh

rm -rf "$ROOT_DIR/tmp/nfqws-keenetic/strategy"
echo -e "* NOTE: nfqws-keenetic is stopped. Start it manually if necessary! \n"
