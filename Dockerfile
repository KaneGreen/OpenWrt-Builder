FROM ubuntu:20.04
RUN useradd -ms /bin/bash runner
RUN apt-get update && \
      apt-get -y install sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN adduser runner sudo
USER runner
WORKDIR /home/runner

RUN sudo -E apt-get install -y asciidoc autoconf automake autopoint binutils build-essential bzip2 ccache curl device-tree-compiler file flex g++ g++-multilib gawk gcc gcc-multilib gettext git git-core haveged help2man jq lib32gcc1 libc6-dev-i386 libelf-dev libglib2.0-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool libz-dev lrzsz make msmtp nano p7zip p7zip-full patch perl-modules python3 python3-distutils python3-pip python3-ply python3-setuptools qemu-utils rsync scons subversion texinfo time uglifyjs unzip upx vim wget xmlto xsltproc zlib1g-dev
RUN wget -qO - https://raw.githubusercontent.com/friendlyarm/build-env-on-ubuntu-bionic/master/install.sh | sed 's/python-/python3-/g' | /bin/bash
RUN git config --global user.name 'GitHub Actions' && git config --global user.email 'noreply@github.com'
RUN sudo -E apt-get clean -y

RUN git clone https://github.com/tiagogbarbosa/R2S-OpenWrt .
RUN sudo chown -R runner:runner ./
RUN cp -f ./SCRIPTS/01_get_ready.sh ./01_get_ready.sh
RUN /bin/bash ./01_get_ready.sh
RUN cd openwrt && \
        cp -f ../SCRIPTS/*.sh ./ && \
        /bin/bash ./02_prepare_package.sh
