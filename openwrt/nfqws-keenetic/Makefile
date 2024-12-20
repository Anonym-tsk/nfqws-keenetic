include $(TOPDIR)/rules.mk

PKG_NAME:=nfqws-keenetic
PKG_VERSION:=$(shell cat ../../VERSION)
PKG_RELEASE:=1
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/nfqws-keenetic
  TITLE:=nfqws-keenetic
  SECTION:=net
  CATEGORY:=Networking
  DEPENDS:=+iptables +iptables-mod-extra +iptables-mod-nfqueue +iptables-mod-filter +iptables-mod-ipopt +iptables-mod-conntrack-extra +ip6tables +ip6tables-mod-nat +ip6tables-extra
  CONFLICTS:=tpws-keenetic
  PKGARCH:=all
  URL:=https://github.com/Anonym-tsk/nfqws-keenetic
  VERSION:=$(PKG_VERSION)
endef

define Package/nfqws-keenetic/description
  NFQWS service
endef

define Build/Prepare
		$(Build/Prepare/Default)
		cp -r ../../* $(PKG_BUILD_DIR)
		$(Build/Patch)
endef

define Build/Compile
		cd $(PKG_BUILD_DIR) && make openwrt
endef

define Package/nfqws-keenetic/install
		$(INSTALL_DIR) $(1)/{etc,tmp,usr,var}
		$(CP) $(PKG_BUILD_DIR)/out/openwrt/data/{etc,tmp,usr,var} $(1)/
endef

define Package/nfqws-keenetic/conffiles
/etc/nfqws/nfqws.conf
/etc/nfqws/user.list
/etc/nfqws/auto.list
/etc/nfqws/exclude.list
endef

define Package/nfqws-keenetic/preinst
$(file <../../common/ipk/preinst)
endef

define Package/nfqws-keenetic/postinst
$(file <../../common/ipk/postinst)
endef

define Package/nfqws-keenetic/postrm
$(file <../../common/ipk/postrm)
endef

$(eval $(call BuildPackage,nfqws-keenetic))

