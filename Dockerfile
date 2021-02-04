FROM ubuntu:20.04
RUN useradd -ms /bin/bash runner
RUN apt-get update && \
      apt-get -y install sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN adduser runner sudo
USER runner
WORKDIR /home/runner
RUN sudo -E ls /