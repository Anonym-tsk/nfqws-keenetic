#!/bin/sh

. /opt/etc/nfqws/nfqws.conf

if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
  exit
fi
[ "$table" != "mangle" ] && exit

# $type is `iptables` or `ip6tables`
/opt/etc/init.d/S51tpws firewall-"$type"
