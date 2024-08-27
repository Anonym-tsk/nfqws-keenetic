#!/bin/sh

ABSOLUTE_FILENAME=`readlink -f "$0"`
HOME_FOLDER=`dirname "$ABSOLUTE_FILENAME"`
BASE_URL="https://raw.githubusercontent.com/Anonym-tsk/nfqws-keenetic/master"

cd /tmp
mkdir -p nfqws-keenetic/etc/nfqws
mkdir -p nfqws-keenetic/etc/init.d
mkdir -p nfqws-keenetic/etc/ndm/netfilter.d
mkdir -p nfqws-keenetic/common

curl -SL# "$BASE_URL/install.sh" -o "nfqws-keenetic/install.sh"
curl -SL# "$BASE_URL/common/install_func.sh" -o "nfqws-keenetic/common/install_func.sh"
curl -SL# "$BASE_URL/etc/nfqws/nfqws.conf" -o "nfqws-keenetic/etc/nfqws/nfqws.conf"
curl -SL# "$BASE_URL/etc/nfqws/user.list" -o "nfqws-keenetic/etc/nfqws/user.list"
curl -SL# "$BASE_URL/etc/nfqws/auto.list" -o "nfqws-keenetic/etc/nfqws/auto.list"
curl -SL# "$BASE_URL/etc/nfqws/exclude.list" -o "nfqws-keenetic/etc/nfqws/exclude.list"
curl -SL# "$BASE_URL/etc/init.d/S51nfqws" -o "nfqws-keenetic/etc/init.d/S51nfqws"
curl -SL# "$BASE_URL/etc/ndm/netfilter.d/100-nfqws.sh" -o "nfqws-keenetic/etc/ndm/netfilter.d/100-nfqws.sh"

chmod +x ./nfqws-keenetic/*.sh
./nfqws-keenetic/install.sh

rm -rf nfqws-keenetic
cd $HOME_FOLDER

exit 0
