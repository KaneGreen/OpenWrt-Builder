FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
RUN useradd -ms /bin/bash runner
RUN apt-get update && \
      apt-get -y install sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN adduser runner sudo
USER runner
WORKDIR /home/runner

ARG DEBIAN_FRONTEND=noninteractive
RUN sudo -E apt-get install -y asciidoc autoconf automake autopoint binutils build-essential bzip2 ccache curl device-tree-compiler file flex g++ g++-multilib gawk gcc gcc-multilib gettext git git-core haveged help2man jq lib32gcc1 libc$
ARG DEBIAN_FRONTEND=noninteractive
RUN wget -qO - https://raw.githubusercontent.com/friendlyarm/build-env-on-ubuntu-bionic/master/install.sh | sed 's/python-/python3-/g' | /bin/bash
RUN git config --global user.name 'GitHub Actions' && git config --global user.email 'noreply@github.com'
RUN sudo -E apt-get clean -y

RUN git clone https://github.com/tiagogbarbosa/R2S-OpenWrt
WORKDIR R2S-OpenWrt
RUN sudo chown -R runner:runner ./
RUN cp -f ./SCRIPTS/01_get_ready.sh ./01_get_ready.sh
RUN /bin/bash ./01_get_ready.sh
WORKDIR openwrt
RUN cp -f ../SCRIPTS/*.sh ./
RUN /bin/bash ./02_prepare_package.sh
RUN /bin/bash ./03_convert_translation.sh
RUN /bin/bash ./04_remove_upx.sh
RUN /bin/bash ./05_create_acl_for_luci.sh -a
RUN cp -f ../SEED/R2S/config.seed .config
RUN cat ../SEED/R2S/more.seed >> .config
RUN make defconfig

RUN let Make_Process=$(nproc)*4
RUN make download -j${Make_Process}

RUN let Make_Process=$(nproc)+1
RUN make toolchain/install -j${Make_Process}

RUN /bin/ls -AF staging_dir/toolchain-*/bin/

RUN let Make_Process=$(nproc)+1
RUN make -j${Make_Process} V=w
