#!/bin/sh

ROOT_DIR=$(readlink -f $(dirname $0)/../../../)
STARTUP_SCRIPT="$ROOT_DIR/etc/init.d/S51nfqws"
PIDFILE="$ROOT_DIR/var/run/nfqws.pid"
CONFFILE="$ROOT_DIR/etc/nfqws/nfqws.conf"

source "$CONFFILE"

if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
  exit
fi
[ "$table" != "mangle" ] && exit

# $type is `iptables` or `ip6tables`
$STARTUP_SCRIPT firewall-"$type"
