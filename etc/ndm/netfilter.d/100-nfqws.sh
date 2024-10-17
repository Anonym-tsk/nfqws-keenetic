#!/bin/sh

PIDFILE="/opt/var/run/nfqws.pid"
if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE") 2>/dev/null; then
  exit
fi
[ "$table" != "mangle" ] && [ "$table" != "nat" ] && exit

# $type is `iptables` or `ip6tables`
/opt/etc/init.d/S51nfqws firewall_"$type"
