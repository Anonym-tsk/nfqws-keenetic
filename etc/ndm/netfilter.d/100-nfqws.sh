#!/bin/sh

PIDFILE="/opt/var/run/nfqws.pid"
if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
  exit
fi
[ "$table" != "mangle" ] && exit

. /opt/etc/nfqws/nfqws.conf

# $type is `iptables` or `ip6tables`
/opt/etc/init.d/S51nfqws firewall_"$type"
