#
# Copyright (C) 2026 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=airoha-hwnat
PKG_VERSION:=6.6.23
PKG_RELEASE:=1
PKG_LICENSE:=Proprietary
PKG_MAINTAINER:=OpenWrt Developers

include $(INCLUDE_DIR)/package.mk

define KernelPackage/airoha-hwnat
  SUBMENU:=Network Support
  TITLE:=Airoha Hardware NAT and NPU Offload Engine
  DEPENDS:=@TARGET_airoha
  FILES:= \
	$(PKG_BUILD_DIR)/modules/fe_core.ko \
	$(PKG_BUILD_DIR)/modules/qdma_lan.ko \
	$(PKG_BUILD_DIR)/modules/qdma_wan.ko \
	$(PKG_BUILD_DIR)/modules/hw_nat.ko \
	$(PKG_BUILD_DIR)/modules/npu_wifi.ko \
	$(PKG_BUILD_DIR)/modules/npu.ko \
	$(PKG_BUILD_DIR)/modules/swnat.ko
  AUTOLOAD:=$(call AutoLoad,30,fe_core qdma_lan qdma_wan hw_nat npu_wifi npu)
endef

define KernelPackage/airoha-hwnat/description
  Kernel modules for Airoha AN7581/EN7581 Hardware Packet Processing Engine (PPE),
  Frame Engine (FE), QDMA, Software NAT fallback, and Neural Processing Unit (NPU) offload.
endef

define KernelPackage/airoha-whnat
  SUBMENU:=Network Support
  TITLE:=Airoha MT7916 Wireless Hardware NAT Offload
  DEPENDS:=+kmod-airoha-hwnat
  FILES:=$(PKG_BUILD_DIR)/modules/mt_whnat_7916.ko
  AUTOLOAD:=$(call AutoLoad,31,mt_whnat_7916)
endef

define KernelPackage/airoha-whnat/description
  Wireless Hardware NAT (WHNAT) module for MediaTek MT7916 on Airoha SoCs.
endef

define Package/airoha-hwnat-tools
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Hardware Accelerators
  TITLE:=Airoha HW NAT user-space control tools & Firewall LuCI integration
  DEPENDS:=+kmod-airoha-hwnat
endef

define Package/airoha-hwnat-tools/description
  User-space control utilities (hw_nat, npu_bridge_cmd, qdmamgr_lan, qdmamgr_wan),
  shared libraries, NPU RISC-V firmware, firewall hotplug hooks, and LuCI flow
  offloading glue for Airoha hardware accelerated NAT. Includes PON and PPPoE
  configuration templates.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) -R ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	true
endef

define KernelPackage/airoha-hwnat/install
	$(INSTALL_DIR) $(1)/lib/firmware/airoha $(1)/userfs
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/firmware/npu_rv32.bin $(1)/lib/firmware/airoha/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/firmware/npu_data.bin $(1)/lib/firmware/airoha/
	ln -sf /lib/firmware/airoha/npu_rv32.bin $(1)/userfs/npu_rv32.bin
	ln -sf /lib/firmware/airoha/npu_data.bin $(1)/userfs/npu_data.bin
	$(INSTALL_DIR) $(1)/etc/modules.d
	$(INSTALL_DATA) ./files/etc/modules.d/30-airoha-hwnat $(1)/etc/modules.d/30-airoha-hwnat
endef

define Package/airoha-hwnat-tools/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/userfs/bin $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/hw_nat $(1)/usr/sbin/hw_nat
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/npu_bridge_cmd $(1)/usr/sbin/npu_bridge_cmd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/qdmamgr_lan $(1)/usr/sbin/qdmamgr_lan
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/qdmamgr_wan $(1)/usr/sbin/qdmamgr_wan
	ln -sf /usr/sbin/hw_nat $(1)/userfs/bin/hw_nat
	ln -sf /usr/sbin/npu_bridge_cmd $(1)/userfs/bin/npu_bridge_cmd
	ln -sf /usr/sbin/qdmamgr_lan $(1)/userfs/bin/qdmamgr_lan
	ln -sf /usr/sbin/qdmamgr_wan $(1)/userfs/bin/qdmamgr_wan

	$(CP) $(PKG_BUILD_DIR)/lib/libapi_lib_utility.so.1.0.0 $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/lib/libapi_lib_ppe.so.1.0.0 $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/lib/libapi_lib_qdmamgr.so.1.0.0 $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/lib/libcompileoption_bsp.so $(1)/usr/lib/
	ln -sf libapi_lib_utility.so.1.0.0 $(1)/usr/lib/libapi_lib_utility.so.1
	ln -sf libapi_lib_utility.so.1.0.0 $(1)/usr/lib/libapi_lib_utility.so
	ln -sf libapi_lib_ppe.so.1.0.0 $(1)/usr/lib/libapi_lib_ppe.so.1
	ln -sf libapi_lib_ppe.so.1.0.0 $(1)/usr/lib/libapi_lib_ppe.so
	ln -sf libapi_lib_qdmamgr.so.1.0.0 $(1)/usr/lib/libapi_lib_qdmamgr.so.1
	ln -sf libapi_lib_qdmamgr.so.1.0.0 $(1)/usr/lib/libapi_lib_qdmamgr.so

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/airoha-hwnat $(1)/etc/init.d/airoha-hwnat

	$(INSTALL_DIR) $(1)/etc/hotplug.d/firewall
	$(INSTALL_BIN) ./files/etc/hotplug.d/firewall/90-airoha-hwnat $(1)/etc/hotplug.d/firewall/90-airoha-hwnat

	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/90-airoha-pppoe-offload $(1)/etc/hotplug.d/iface/90-airoha-pppoe-offload

	$(INSTALL_DIR) $(1)/usr/share/airoha-hwnat
	$(INSTALL_BIN) ./files/usr/share/airoha-hwnat/firewall.include $(1)/usr/share/airoha-hwnat/firewall.include

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/99-airoha-hwnat-firewall $(1)/etc/uci-defaults/99-airoha-hwnat-firewall
	$(INSTALL_BIN) ./files/etc/uci-defaults/90-airoha-pon-network $(1)/etc/uci-defaults/90-airoha-pon-network

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/etc/config/network.pon.template $(1)/etc/config/network.pon.template
endef

$(eval $(call KernelPackage,airoha-hwnat))
$(eval $(call KernelPackage,airoha-whnat))
$(eval $(call BuildPackage,airoha-hwnat-tools))
