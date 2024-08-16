#!/bin/sh

CONFDIR=/opt/etc/nfqws
CONFFILE=$CONFDIR/nfqws.conf
LISTFILE=$CONFDIR/user.list
LISTAUTOFILE=$CONFDIR/auto.list
LISTEXCLUDEFILE=$CONFDIR/exclude.list
LISTLOG=/opt/var/log/nfqws.log
NFQWS_BIN=/opt/usr/bin/nfqws
INIT_SCRIPT=/opt/etc/init.d/S51nfqws
NETFILTER_SCRIPT=/opt/etc/ndm/netfilter.d/100-nfqws.sh

stop_func() {
  if [ -f "$INIT_SCRIPT" ]; then
    $INIT_SCRIPT stop
  fi
}

start_func() {
  if [ -f "$INIT_SCRIPT" ]; then
    $INIT_SCRIPT start
  fi
}

show_interfaces_func() {
  echo -e "\n----------------------"
  ip addr show | awk -F" |/" '{gsub(/^ +/,"")}/inet /{print $(NF), $2}'
}

read_yes_or_abort_func() {
  read yn
  case $yn in
    [Yy]* )
      ;;
    * )
      echo "Installation aborted"
      exit
      ;;
  esac
}

begin_install_func() {
  echo -e "\nBegin install? y/N"
  read_yes_or_abort_func
}

begin_uninstall_func() {
  echo -e "\nBegin uninstall? y/N"
  read_yes_or_abort_func
}

remove_all_files_func() {
  rm -f $CONFFILE
  rm -f $NFQWS_BIN
  rm -f $INIT_SCRIPT
  rm -f $NETFILTER_SCRIPT
  rm -f $LISTLOG
}

remove_list_func() {
  echo -e "\nRemove hosts list? y/N"
  read yn
  case $yn in
    [Yy]* )
      rm -f $LISTFILE
      rm -f $LISTAUTOFILE
      rm -f $LISTEXCLUDEFILE
      ;;
  esac
}

check_old_config_func() {
  if [ -f "$CONFFILE" ]; then
    echo -e "\nOld config file found: $CONFFILE. It will be overwritten. Continue? y/N"
    read_yes_or_abort_func
  fi
}

install_packages_func() {
  opkg update
  opkg upgrade busybox
  opkg install iptables
}

config_copy_files_func() {
  cp -f $HOME_FOLDER/etc/init.d/S51nfqws $INIT_SCRIPT
  chmod +x $INIT_SCRIPT

  cp -f $HOME_FOLDER/etc/ndm/netfilter.d/100-nfqws.sh $NETFILTER_SCRIPT
  chmod +x $NETFILTER_SCRIPT

  mkdir -p $CONFDIR
  cp -f $HOME_FOLDER/etc/nfqws/nfqws.conf $CONFFILE
}

config_copy_list_func() {
  if [ -f "$LISTFILE" ]; then
    echo -e "\nOld hosts list file found: $LISTFILE. Overwrite? y/N"
    read yn
    case $yn in
      [Yy]* )
        cp -f $HOME_FOLDER/etc/nfqws/user.list $LISTFILE
        cp -f $HOME_FOLDER/etc/nfqws/auto.list $LISTAUTOFILE
        cp -f $HOME_FOLDER/etc/nfqws/exclude.list $LISTEXCLUDEFILE
        ;;
    esac
  else
    cp -f $HOME_FOLDER/etc/nfqws/user.list $LISTFILE
    cp -f $HOME_FOLDER/etc/nfqws/auto.list $LISTAUTOFILE
    cp -f $HOME_FOLDER/etc/nfqws/exclude.list $LISTEXCLUDEFILE
  fi
}

config_select_arch_func() {
  if [ -z "$ARCH" ]; then
    echo -e "\nSelect the router architecture: mipsel (default), mips, aarch64, arm"
    echo "  mipsel  - KN-1010/1011, KN-1810, KN-1910/1912, KN-2310, KN-2311, KN-2610, KN-2910, KN-3810"
    echo "  mips    - KN-2410, KN-2510, KN-2010, KN-2012, KN-2110, KN-2112, KN-3610"
    echo "  aarch64 - KN-2710, KN-1811"
    echo "  arm     - Other arm-based devices"
    read ARCH
  fi

  if [ "$ARCH" == "mips" ]; then
    NFQWS_URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-msb/nfqws"
  elif [ "$ARCH" == "arm" ]; then
    NFQWS_URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/arm/nfqws"
  elif [ "$ARCH" == "aarch64" ]; then
    NFQWS_URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/aarch64/nfqws"
  else
    ARCH="mipsel"
    NFQWS_URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-lsb/nfqws"
  fi

  echo "Selected architecture: $ARCH"
  curl -SL# "$NFQWS_URL" -o "$NFQWS_BIN"
  chmod +x $NFQWS_BIN
}

config_select_mode_func() {
  if [ -z "$MODE" ]; then
    echo -e "\nSelect working mode: auto (default), list, all"
    echo "  auto - automatically detects blocked resources and adds them to the list"
    echo "  list - applies rules only to domains in the list $LISTFILE"
    echo "  all  - applies rules to all traffic except domains from list $LISTEXCLUDEFILE"
    read MODE
  fi

  if [ "$MODE" == "list" ]; then
    EXTRA_ARGS="--hostlist=$LISTFILE"
  elif [ "$MODE" == "all" ]; then
    EXTRA_ARGS="--hostlist-exclude=$LISTEXCLUDEFILE"
  else
    MODE="auto"
    EXTRA_ARGS="--hostlist=$LISTFILE --hostlist-auto=$LISTAUTOFILE --hostlist-auto-debug=$LISTLOG --hostlist-exclude=$LISTEXCLUDEFILE"
  fi
  echo "Selected mode: $MODE"

  sed -i "s#INPUT_EXTRA_ARGS#$EXTRA_ARGS#" $CONFFILE
}

config_interface_func() {
  if [ -z "$BIND_IFACE" ]; then
    echo -e "\nEnter the provider interface name from the list above, e.g. eth3 (default) or nwg1"
    echo "You can specify multiple interfaces separated by space, e.g. eth3 nwg1"
    read BIND_IFACE
  fi
  if [ -z "$BIND_IFACE" ]; then
    BIND_IFACE="eth3"
  fi
  echo "Selected interface: $BIND_IFACE"

  sed -i "s#INPUT_ISP_INTERFACE#$BIND_IFACE#" $CONFFILE
}

config_ipv6_func() {
  echo -e "\nDisable IPv6 support (enabled by default)? y/N"
  read yn
  case $yn in
    [Yy]* )
      sed -i "s#IPV6_ENABLED=1#IPV6_ENABLED=0#" $CONFFILE
      ;;
  esac
}
