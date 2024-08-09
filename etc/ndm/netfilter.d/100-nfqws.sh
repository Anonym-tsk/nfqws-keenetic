#!/bin/sh

. /opt/etc/nfqws/nfqws.conf

if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
  exit
fi
[ "$type" == "ip6tables" ] && exit
[ "$table" != "mangle" ] && exit

/opt/etc/init.d/S51nfqws firewall
