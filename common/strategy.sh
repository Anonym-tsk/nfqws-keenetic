#!/bin/sh
set -e

cleanup() {
    rm -rf "$ROOT_DIR/tmp/nfqws-keenetic/strategy" 2>/dev/null || true
}
trap cleanup EXIT

if [ -f "/opt/etc/init.d/S51nfqws" ]; then
    ROOT_DIR=/opt
    /opt/etc/init.d/S51nfqws stop || true
else
    ROOT_DIR=
    if [ -f "/etc/init.d/nfqws-keenetic" ]; then
        /etc/init.d/nfqws-keenetic stop || true
    fi
fi

mkdir -p "$ROOT_DIR/tmp/nfqws-keenetic/strategy/zapret"
cd "$ROOT_DIR/tmp/nfqws-keenetic/strategy"

RELEASE_URL=$(curl -s https://api.github.com/repos/bol-van/zapret/releases/latest \
    | grep browser_download_url \
    | grep 'embedded.tar.gz' \
    | cut -d '"' -f 4 \
    | head -1)

if [ -z "$RELEASE_URL" ]; then
    echo "Error: Unable to get URL from GitHub. Please check your internet connection(or DNS settings) or curl." >&2
    echo "TIP: Try 'curl https://api.github.com/repos/bol-van/zapret/releases/latest | grep browser_download_url | grep 'embedded.tar.gz''" >&2
    exit 1
fi
#echo "Debug: URL received: $RELEASE_URL"

curl -SLf "$RELEASE_URL" -o zapret.tar.gz
if [ ! -s zapret.tar.gz ]; then
    echo "Error: File download failed or file is empty." >&2
    exit 1
fi

tar -C zapret -xzf zapret.tar.gz
if [ ! -d "zapret" ]; then
    echo "Error: The zapret directory was not created after unpacking." >&2
    exit 1
fi

ZAPRET_DIR=$(ls -d zapret/*/ 2>/dev/null | head -1)
if [ -z "$ZAPRET_DIR" ]; then
    echo "Error: Subdirectory not found in zapret/ after extraction." >&2
    exit 1
fi
cd "$ZAPRET_DIR"

if [ ! -x "./install_bin.sh" ]; then
    echo "Error: install_bin.sh not found or not executable." >&2
    exit 1
fi
./install_bin.sh

if [ ! -x "./blockcheck.sh" ]; then
    echo "Error: blockcheck.sh not found or not executable." >&2
    exit 1
fi
SECURE_DNS=1 FWTYPE=iptables SKIP_TPWS=1 ./blockcheck.sh

echo "* NOTE: nfqws-keenetic is stopped. Start it manually if necessary!"
