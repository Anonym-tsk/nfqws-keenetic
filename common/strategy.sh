#!/bin/sh

ROOT_DIR=
INIT_SCRIPT="/etc/init.d/nfqws-keenetic"
if [ -f "/opt/usr/bin/nfqws" ]; then
  ROOT_DIR="/opt"
  INIT_SCRIPT="/opt/etc/init.d/S51nfqws"
fi

source "$ROOT_DIR/etc/nfqws/nfqws.conf"

NFQWS_BIN="$ROOT_DIR/usr/bin/nfqws"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
CURL_MAX_TIME=2
DOMAIN="$1"
FULL_CHECK=0
if [ "$2" = "--full" ]; then
  FULL_CHECK=1
fi

test_func() {
  # $1 - domain
  # $2 - nfqws args

  $INIT_SCRIPT firewall_iptables
  $INIT_SCRIPT firewall_ip6tables
  $NFQWS_BIN --daemon --user=nobody --qnum=$NFQUEUE_NUM $2

  curl -SLs -A "$USER_AGENT" --max-time $CURL_MAX_TIME "https://$1" -o /dev/null 2>&1 > /dev/null
  code=$?
  if [ "$code" -eq "0" ]; then
    echo "Found strategy:"
    echo -e "$2\n"
  fi

  killall nfqws
}

full_check_func() {
  DESYNC_ARGS="fake,disorder2 fake,split2 fake,split"
  SPLIT_ARGS="1 3 7"
  TTL_ARGS="0 6 7 12"
  FOOLING_ARGS="md5sig badseq badsum md5sig,badseq md5sig,badsum"

  for DESYNC in $DESYNC_ARGS; do
    for SPLIT in $SPLIT_ARGS; do
      for TTL in $TTL_ARGS; do
        for FOOLING in $FOOLING_ARGS; do
          ARGS="--dpi-desync=$DESYNC --dpi-desync-split-pos=$SPLIT --dpi-desync-ttl=$TTL --dpi-desync-fooling=$FOOLING"
          test_func "$DOMAIN" "$ARGS"
        done
      done
    done
  done
}

fast_check_func() {
  ARGS="--dpi-desync=fake,disorder2 --dpi-desync-split-pos=1 --dpi-desync-ttl=6 --dpi-desync-fooling=md5sig,badseq,badsum"
  test_func "$DOMAIN" "$ARGS"

  ARGS="--dpi-desync=fake,disorder2 --dpi-desync-split-pos=1 --dpi-desync-ttl=12 --dpi-desync-fooling=md5sig,badseq,badsum"
  test_func "$DOMAIN" "$ARGS"

  ARGS="--dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-ttl=6 --dpi-desync-fooling=md5sig,badseq,badsum"
  test_func "$DOMAIN" "$ARGS"

  ARGS="--dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-ttl=12 --dpi-desync-fooling=md5sig,badseq,badsum"
  test_func "$DOMAIN" "$ARGS"

  ARGS="--dpi-desync=fake,split2 --dpi-desync-ttl=0 --dpi-desync-fooling=md5sig,badsum"
  test_func "$DOMAIN" "$ARGS"

  ARGS="--dpi-desync=fake,disorder2 --dpi-desync-split-pos=1 --dpi-desync-ttl=6 --dpi-desync-fooling=md5sig,badseq"
  test_func "$DOMAIN" "$ARGS"

  ARGS="--dpi-desync=fake,disorder2 --dpi-desync-split-pos=1 --dpi-desync-ttl=6 --dpi-desync-fooling=md5sig,badsum"
  test_func "$DOMAIN" "$ARGS"
}

run() {
  echo "Testing domain: $DOMAIN"

  # Prepare
  $INIT_SCRIPT stop
  killall nfqws
  $INIT_SCRIPT kernel_modules

  if [ "$FULL_CHECK" -eq "1" ]; then
    full_check_func
  else
    fast_check_func
  fi

  # Cleanup
  $INIT_SCRIPT firewall_stop
}

run
