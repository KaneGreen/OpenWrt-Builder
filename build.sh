#!/bin/bash

rm -rf luci-lienol openwrt openwrt-lienol packages-lienol
cp -f ./SCRIPTS/01_get_ready.sh ./01_get_ready.sh

/bin/bash ./01_get_ready.sh
cd openwrt
cp -f ../SCRIPTS/*.sh ./
/bin/bash ./02_prepare_package.sh
/bin/bash ./03_convert_translation.sh
/bin/bash ./04_remove_upx.sh
/bin/bash ./05_create_acl_for_luci.sh -a
cp -f ../SEED/R2S/config.seed  .config
cat   ../SEED/R2S/more.seed >> .config
make defconfig

let Make_Process=$(nproc)*4
make download -j${Make_Process}

let Make_Process=$(nproc)+1
make toolchain/install -j${Make_Process}

/bin/ls -AF staging_dir/toolchain-*/bin/

let Make_Process=$(nproc)+1
make -j${Make_Process} V=w