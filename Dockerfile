FROM ubuntu:20.04
RUN useradd -ms /bin/bash runner
RUN apt-get update && \
      apt-get -y install sudo
RUN adduser runner sudo
USER runner
WORKDIR /home/runner
