#!/bin/bash
# 如果没有环境变量或无效，则默认构建R2S版本
[ -f "../SEED/${MYOPENWRTTARGET}.config.seed" ] || MYOPENWRTTARGET='R2S'
echo "==> Now building: ${MYOPENWRTTARGET}"

alias wget="$(which wget) --https-only --retry-connrefused"
set -e
set -x
# 获取 Feeds 更新
./scripts/feeds update -a
./scripts/feeds install -a

# 更新 FW4
#rm -rf ./package/network/config/firewall4
#cp -rf ../Openwrt_Main/package/network/config/firewall4 ./package/network/config/firewall4

# TCP optimizations
mv -f ../PATCH/kernel/6.7_Boost_For_Single_TCP_Flow/*.patch                                                ./target/linux/generic/backport-6.6/
mv -f ../PATCH/kernel/6.8_Boost_TCP_Performance_For_Many_Concurrent_Connections-bp_but_put_in_hack/*.patch ./target/linux/generic/hack-6.6/
mv -f ../PATCH/kernel/6.8_Better_data_locality_in_networking_fast_paths-bp_but_put_in_hack/*.patch         ./target/linux/generic/hack-6.6/
# UDP optimizations
mv -f ../PATCH/kernel/6.7_FQ_packet_scheduling/*.patch ./target/linux/generic/backport-6.6/
# BBR v3
mv -f ../PATCH/kernel/BBRv3/*.patch                    ./target/linux/generic/backport-6.6/
if [ "${MYOPENWRTTARGET}" == 'R2S' ] ; then
# Show ARM64 model name
  mv -f ../PATCH/kernel/ARM/*.patch                    ./target/linux/generic/hack-6.6/
else 
# LRNG
  mv -f ../PATCH/kernel/LRNG/*.patch                     ./target/linux/generic/hack-6.6/
  echo '
# CONFIG_RANDOM_DEFAULT_IMPL is not set
CONFIG_LRNG=y
CONFIG_LRNG_DEV_IF=y
# CONFIG_LRNG_IRQ is not set
CONFIG_LRNG_JENT=y
CONFIG_LRNG_CPU=y
# CONFIG_LRNG_SCHED is not set
CONFIG_LRNG_SELFTEST=y
# CONFIG_LRNG_SELFTEST_PANIC is not set
' >> ./target/linux/generic/config-6.6
fi
# PPP: fix IPv6-PD
wget -qO - https://github.com/immortalwrt/immortalwrt/commit/9d852a05bd50b1c332301eecbcac1fa71be637d6.patch | patch -p1
# WireGuard
mv -f ../PATCH/kernel/WireGuard/*.patch ./target/linux/generic/hack-6.6/

### Fullcone-NAT 部分 ###
# bcmfullcone
mv -f ../PATCH/kernel/bcmfullcone/* ./target/linux/generic/hack-6.6/
# set nf_conntrack_expect_max for fullcone
wget -qO - https://github.com/openwrt/openwrt/commit/bbf39d07fd43977f55a4b9ba9e384cdf8a0d2b50.patch | patch -p1
echo "net.netfilter.nf_conntrack_helper = 1"          >> package/kernel/linux/files/sysctl-nf-conntrack.conf
echo "net.netfilter.nf_conntrack_tcp_max_retrans = 5" >> package/kernel/linux/files/sysctl-nf-conntrack.conf
# FW4
mkdir -p package/network/config/firewall4/patches
mv -f ../PATCH/pkgs/firewall/firewall4_patches/*.patch ./package/network/config/firewall4/patches/
mkdir -p package/libs/libnftnl/patches
mv -f ../PATCH/pkgs/firewall/libnftnl/*.patch          ./package/libs/libnftnl/patches/
sed -i '/PKG_INSTALL:=/iPKG_FIXUP:=autoreconf'         ./package/libs/libnftnl/Makefile
mkdir -p package/network/utils/nftables/patches
mv -f ../PATCH/pkgs/firewall/nftables/*.patch          ./package/network/utils/nftables/patches/
# Patch LuCI 以增添 FullCone 开关
pushd feeds/luci
  patch -p1 < ../../../PATCH/pkgs/firewall/luci/0001-luci-app-firewall-add-nft-fullcone-and-bcm-fullcone-.patch
popd

### Other Kernel Hack 部分 ###
# make olddefconfig
wget -qO - https://github.com/openwrt/openwrt/commit/c21a357093afc1ffeec11b6bb63d241899c1cf68.patch | patch -p1
# igc-fix
if [ "${MYOPENWRTTARGET}" == 'x86' ] ; then
  wget -P ./target/linux/x86/patches-6.6/ https://github.com/coolsnowwolf/lede/raw/refs/heads/master/target/linux/x86/patches-6.6/996-intel-igc-i225-i226-disable-eee.patch
fi

### 获取额外的基础软件包 ###
# 更换为 ImmortalWrt Uboot 以及 Target
if [ "${MYOPENWRTTARGET}" == 'R2S' ] ; then
  rm -rf ./target/linux/rockchip
  mv -f ../Immortalwrt_2410/target/linux/rockchip ./target/linux/rockchip
  mv -f ../PATCH/kernel/Rockchip/*                ./target/linux/rockchip/patches-6.6/
  rm -rf ./package/boot/{rkbin,uboot-rockchip,arm-trusted-firmware-rockchip}
  mv -f ../Immortalwrt_2410/package/boot/uboot-rockchip                ./package/boot/uboot-rockchip
  mv -f ../Immortalwrt_2410/package/boot/arm-trusted-firmware-rockchip ./package/boot/arm-trusted-firmware-rockchip
  sed -i '/REQUIRE_IMAGE_METADATA/d' ./target/linux/rockchip/armv8/base-files/lib/upgrade/platform.sh
fi
# Fix missing kmod-drm-lima
mv -f ../Immortalwrt_2410/package/kernel/linux/modules/video.mk ./package/kernel/linux/modules/video.mk

# 更换 golang 版本
rm -rf ./feeds/packages/lang/golang
mv -f ../Openwrt_PKG_Master/lang/golang/ ./feeds/packages/lang/golang/
# Node.js 使用预编译二进制
rm -rf ./feeds/packages/lang/node ./package/new/feeds_packages_lang_node-prebuilt
mv -f ../OpenWrt-Add/feeds_packages_lang_node-prebuilt/ ./feeds/packages/lang/node/
### ADD PKG 部分 ###
cp -rf ../OpenWrt-Add ./package/new
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,frp,microsocks,shadowsocks-libev,zerotier,daed}
rm -rf feeds/luci/applications/{luci-app-frps,luci-app-frpc,luci-app-zerotier,luci-app-filemanager}
rm -rf feeds/packages/utils/coremark

### 获取额外的 LuCI 应用、主题和依赖 ###
# mount cgroupv2
pushd feeds/packages
  patch -p1 < ../../../PATCH/pkgs/cgroupfs-mount/0001-fix-cgroupfs-mount.patch
popd
mkdir -p feeds/packages/utils/cgroupfs-mount/patches
mv -f ../PATCH/pkgs/cgroupfs-mount/900-mount-cgroup-v2-hierarchy-to-sys-fs-cgroup-cgroup2.patch   ./feeds/packages/utils/cgroupfs-mount/patches/
mv -f ../PATCH/pkgs/cgroupfs-mount/901-fix-cgroupfs-umount.patch                                  ./feeds/packages/utils/cgroupfs-mount/patches/
mv -f ../PATCH/pkgs/cgroupfs-mount/902-mount-sys-fs-cgroup-systemd-for-docker-systemd-suppo.patch ./feeds/packages/utils/cgroupfs-mount/patches/
# fstool patch
wget -qO - https://github.com/coolsnowwolf/lede/commit/8a4db762497b79cac91df5e777089448a2a71f7c.patch | patch -p1
# 动态DNS 自启动相关
sed -i '/boot()/,+2d' feeds/packages/net/ddns-scripts/files/etc/init.d/ddns
# IPv6 兼容助手
patch -p1 < ../PATCH/pkgs/odhcp6c/1002-odhcp6c-support-dhcpv6-hotplug.patch
# odhcpd IPv6
mkdir -p  package/network/services/odhcpd/patches
mv -f  ../PATCH/pkgs/odhcpd/0001-odhcpd-improve-RFC-9096-compliance.patch ./package/network/services/odhcpd/patches/
wget -P ./package/network/services/odhcpd/patches/ https://github.com/openwrt/odhcpd/pull/219.patch
wget -P ./package/network/services/odhcpd/patches/ https://github.com/openwrt/odhcpd/pull/242.patch
mkdir -p  package/network/ipv6/odhcp6c/patches
wget -P ./package/network/ipv6/odhcp6c/patches/ https://github.com/openwrt/odhcp6c/pull/75.patch
wget -P ./package/network/ipv6/odhcp6c/patches/ https://github.com/openwrt/odhcp6c/pull/80.patch
wget -P ./package/network/ipv6/odhcp6c/patches/ https://github.com/openwrt/odhcp6c/pull/82.patch
wget -P ./package/network/ipv6/odhcp6c/patches/ https://github.com/openwrt/odhcp6c/pull/83.patch
wget -P ./package/network/ipv6/odhcp6c/patches/ https://github.com/openwrt/odhcp6c/pull/84.patch
wget -P ./package/network/ipv6/odhcp6c/patches/ https://github.com/openwrt/odhcp6c/pull/90.patch
wget -P ./package/network/ipv6/odhcp6c/patches/ https://github.com/openwrt/odhcp6c/pull/98.patch
# watchcat
echo > ./feeds/packages/utils/watchcat/files/watchcat.config

### 最后的收尾工作 ###
# 删除已有配置
rm -rf .config
# 停用内核配置“将所有警告视为错误”，这是因为一些第三方PATCH不够严谨
sed -i 's,CONFIG_WERROR=y,# CONFIG_WERROR is not set,g' ./target/linux/generic/config-6.6
# 平台优化
case ${MYOPENWRTTARGET} in
  R2S)
    sed -i -e 's/-Os/-O2/g' -e 's,-mcpu=generic,-march=armv8-a,g' ./include/target.mk
    ;;
  x86)
    sed -i -e 's/-Os/-O2 -march=x86-64-v2/g' ./include/target.mk # 不再考虑过于老旧的平台
    echo '#!/bin/sh
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

if grep -q "Default string" /tmp/sysinfo/model 2> /dev/null; then
    echo should be fine
else
    echo "Generic PC" > /tmp/sysinfo/model
fi

status=$(cat /sys/devices/system/cpu/intel_pstate/status)

if [ "$status" = "passive" ]; then
    echo "active" | tee /sys/devices/system/cpu/intel_pstate/status
fi

exit 0
'> ./package/base-files/files/etc/rc.local
    ;;
esac

# 翻译及部分功能优化
if [ "${MYOPENWRTTARGET}" != 'R2S' ] ; then
  sed -i '/openssl\.cnf/d' ../PATCH/default_conf/zzz-default-settings
  sed -i '/upnp/Id'        ../PATCH/default_conf/zzz-default-settings
fi
mv -f ../PATCH/default_conf/zzz-default-settings ./package/new/addition-trans-zh/files/zzz-default-settings

### 6. vermagic ###
source ../OPENWRT_GIT_TAG
LATESTRELEASE=${LATESTRELEASE:1}
case ${MYOPENWRTTARGET} in
  R2S)
    wget "https://downloads.openwrt.org/releases/${LATESTRELEASE}/targets/rockchip/armv8/profiles.json"
    ;;
  x86)
    wget "https://downloads.openwrt.org/releases/${LATESTRELEASE}/targets/x86/64/profiles.json"
    ;;
esac
jq -r '.linux_kernel.vermagic' profiles.json > .vermagic
sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk

# 预配置一些插件
cp -rf ../PATCH/files ./files

# 给root用户添加vim和screen的配置文件
mkdir -p                   ./package/base-files/files/root/
mv -f ../PRECONFS/vimrc    ./package/base-files/files/root/.vimrc
mv -f ../PRECONFS/screenrc ./package/base-files/files/root/.screenrc

# 删除多余的代码库
rm -rf ../Openwrt_Main/ ../Openwrt_PKG_Master/ ../Immortalwrt_2410/ ../Openwrt_Main/ 

unalias wget
sync
