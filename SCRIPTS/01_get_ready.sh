#!/bin/bash
set -e
set -x
# get the latest release version of 25.12
LATESTRELEASE=$(curl -sSf -H 'X-GitHub-Api-Version:2026-03-10' -H 'Accept: application/vnd.github+json' https://api.github.com/repos/openwrt/openwrt/tags | jq '.[].name' -r | grep -v 'rc' | grep 'v25' | sort -r | head -n 1)

echo "LATESTRELEASE=$LATESTRELEASE" >> ./OPENWRT_GIT_TAG

#git clone --single-branch -b 'openwrt-25.12'  --depth 1  https://github.com/openwrt/openwrt.git openwrt_snapshot
git clone --single-branch -b "$LATESTRELEASE" --depth 1  https://github.com/openwrt/openwrt.git openwrt

#rm -rf ./openwrt/package/
#mv -f  ./openwrt_snapshot/package            ./openwrt/package
#mv -f  ./openwrt_snapshot/feeds.conf.default ./openwrt/feeds.conf.default
#rm -rf ./openwrt_snapshot/
#pushd openwrt
#  rm -rf ./package/base-files/ ./package/firmware/ ./package/kernel/ ./package/Makefile
#  git checkout HEAD package/base-files/
#  git checkout HEAD package/firmware/
#  git checkout HEAD package/kernel/
#  git checkout HEAD package/Makefile
#popd

# 获取额外代码
git clone -b main          --depth 1 https://github.com/openwrt/openwrt.git            Openwrt_Main/
sleep 3
git clone -b master        --depth 1 https://github.com/openwrt/packages.git           Openwrt_PKG_Master/
sleep 3
git clone -b master        --depth 1 https://github.com/QiuSimons/OpenWrt-Add.git      OpenWrt-Add/
exit 0
