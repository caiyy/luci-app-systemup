include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-systemup
PKG_VERSION=5.0
PKG_RELEASE:=7.3

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/luci-app-systemup
    SECTION:=luci
    CATEGORY:=LuCI
    SUBMENU:=3. Applications
    TITLE:=AutoUpdateSystem
    PKGARCH:=all
    DEPENDS:= +curl +wget
endef

define Package/luci-app-systemup/description
    AutoUpdateSystem
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-systemup/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/systemup
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_CONF) ./files/root/etc/config/systemup $(1)/etc/config/systemup
	$(INSTALL_BIN) ./files/root/etc/init.d/systemup $(1)/etc/init.d/systemup
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/model/cbi/systemup/log.lua $(1)/usr/lib/lua/luci/model/cbi/systemup/log.lua
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/model/cbi/systemup/setup.lua $(1)/usr/lib/lua/luci/model/cbi/systemup/setup.lua
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/controller/systemup.lua $(1)/usr/lib/lua/luci/controller/systemup.lua
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/systemup.sh $(1)/usr/sbin
endef
$(eval $(call BuildPackage,luci-app-systemup))
