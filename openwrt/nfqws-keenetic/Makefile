include $(TOPDIR)/rules.mk

PKG_NAME:=nfqws-keenetic
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/nfqws-keenetic
  TITLE:=nfqws-keenetic
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+iptables +iptables-mod-extra +iptables-mod-nfqueue +iptables-mod-filter +iptables-mod-ipopt +iptables-mod-conntrack-extra +ip6tables +ip6tables-mod-nat +ip6tables-extra
  CONFLICTS:=tpws-keenetic
  PKGARCH:=all
  URL:=https://github.com/Anonym-tsk/nfqws-keenetic
endef

# Package description; a more verbose description on what our package does
define Package/nfqws-keenetic/description
  NFQWS service
endef

define Build/Prepare
		$(Build/Prepare/Default)
		cp -r ../../* $(PKG_BUILD_DIR)
		$(Build/Patch)
endef

define Build/Compile
		cd $(PKG_BUILD_DIR) && make openwrt_new
endef

define Package/nfqws-keenetic/install
		$(INSTALL_DIR) $(1)/{etc,tmp,usr,var}
		$(CP) $(PKG_BUILD_DIR)/out/openwrt-new/data/{etc,tmp,usr,var} $(1)/
endef

define Package/nfqws-keenetic/conffiles
/etc/nfqws/nfqws.conf
/etc/nfqws/user.list
/etc/nfqws/auto.list
/etc/nfqws/exclude.list
endef

define Package/nfqws-keenetic/preinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
CONFFILE="/etc/nfqws/nfqws.conf"
LISTFILE="/etc/nfqws/user.list"

# Set `install` or `upgrade` for postinst script
echo "$$1" > "/tmp/nfqws_install_type"

# Migrations
NEED_MIGRATION_CONF=0
NEED_MIGRATION_LIST=0

CURRENT_VERSION=5  # TODO: Set from current config
INSTALLED_VERSION=$(grep -E '^CONFIG_VERSION=' "$$CONFFILE" 2>/dev/null | grep -oE '[0-9]+$')

if [ -z "$$INSTALLED_VERSION" ]; then
  NEED_MIGRATION_CONF=1
elif [ "$$INSTALLED_VERSION" -lt "$$CURRENT_VERSION" ]; then
  NEED_MIGRATION_CONF=1
fi

if [ $$NEED_MIGRATION_CONF -ne 0 ]; then
  if [ -f "$$CONFFILE" ]; then
    # Old config
    mv "$$CONFFILE" "$$CONFFILE-old"
    echo "Old configuration file was moved to $$CONFFILE-old"
  fi

  # We need clean install
  echo "install" > "/tmp/nfqws_install_type"
fi

if [ $$NEED_MIGRATION_LIST -ne 0 ]; then
  if [ -f "$$LISTFILE" ]; then
    # Old list
    mv "$$LISTFILE" "$$LISTFILE-old"
    echo "user.list file was moved to $$LISTFILE-old"
  fi
fi
exit 0
endef

define Package/nfqws-keenetic/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
# Install binary
OWRT_FEEDS="/etc/opkg/distfeeds.conf"
CONFFILE=/etc/nfqws/nfqws.conf

if [ -f "$$OWRT_FEEDS" ]; then
    ARCH=$$(cat "$$OWRT_FEEDS" | grep -oE 'mips_|mipsel_|aarch64_|arm_|i386|x86_64' | head -n 1)
fi
if [ -n "$$ARCH" ]; then
    case "$$ARCH" in
      "mips-3"|"mips_") ARCH="mips" ;;
      "mipsel-3"|"mipsel_") ARCH="mipsel" ;;
      "aarch64-3"|"aarch64_") ARCH="aarch64" ;;
      "armv7"|"arm_") ARCH="armv7" ;;
      "i386"|"i686") ARCH="x86" ;;
      "x86_64") ARCH="x86_64" ;;
    esac
fi

if [ -z $$ARCH ]; then
    ARCH=$$(uname -m | grep -oE 'mips|mipsel|aarch64|armv7|i386|i686|x86_64')
    if [ "$$ARCH" == "mips" ]; then
      if grep -qE 'system type.*MediaTek' /proc/cpuinfo; then
        ARCH="mipsel"
      fi
    elif [ "$$ARCH" == "i386" ] || [ "$$ARCH" == "i686" ]; then
      ARCH="x86"
    fi
fi

if [ -z $$ARCH ]; then
    echo "Failed to detect architecture"
    exit 1
fi

echo "Detected arch: $$ARCH"

cp -f "/tmp/nfqws_binary/nfqws-$$ARCH" "/usr/bin/nfqws"
chmod +x "/usr/bin/nfqws"
rm -rf "/tmp/nfqws_binary"

# Install configuration
NFQWS_INSTALL_TYPE="install"
if [ -f "/tmp/nfqws_install_type" ]; then
    # Set in preinst script
    NFQWS_INSTALL_TYPE=$$(cat "/tmp/nfqws_install_type")
    rm -f "/tmp/nfqws_install_type"
fi

case "$$NFQWS_INSTALL_TYPE" in
    install)
      # Interface
      DEF_IFACE=$$(route | grep '^default' | grep -o '[^ ]*$$')
      sed -i -E "s#^ISP_INTERFACE=\".+\"#ISP_INTERFACE=\"$$DEF_IFACE\"#" $$CONFFILE
      echo "Detected ISP interface: $$DEF_IFACE"

      # IPv6
      ipv6_enabled=$$(ip -f inet6 addr show dev "$$DEF_IFACE" 2>/dev/null | grep "scope global")
      [[ -z "$$ipv6_enabled" ]] && IPV6=1 || IPV6=0
      sed -i -E "s#^IPV6_ENABLED=(1|0)#IPV6_ENABLED=$$IPV6#" $$CONFFILE
      echo "Detected IPv6: $$IPV6"

      # Config paths
      sed -i -E "s#/opt/#/#g" $$CONFFILE

      echo "Current working mode: auto"
      echo "You can change settings in the configuration file: $$CONFFILE"

      echo "Installation successful"
      ;;
    *)
      # Do nothing
      ;;
esac
exit 0
endef

define Package/nfqws-keenetic/postrm
#!/bin/sh
# Remove binary file
rm -f /usr/bin/nfqws

case "$$1" in
  upgrade)
    # Do nothing
    ;;
  *)
    # Remove all data
      rm -f /var/log/nfqws.log
      echo -e "\nRemove lists and config? y/N"
      read yn
      case $$yn in
        [Yy]* )
          rm -rf /etc/nfqws
          ;;
      esac
    echo "Uninstallation successful"
    ;;
esac
exit 0
endef

$(eval $(call BuildPackage,nfqws-keenetic))

