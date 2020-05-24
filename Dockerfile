FROM innovanon/poobuntu:latest
MAINTAINER Innovations Anonymous <InnovAnon-Inc@protonmail.com>

LABEL version="1.0"                                                     \
      maintainer="Innovations Anonymous <InnovAnon-Inc@protonmail.com>" \
      about="docker wine"                                               \
      org.label-schema.build-date=$BUILD_DATE                           \
      org.label-schema.license="PDL (Public Domain License)"            \
      org.label-schema.name="docker-wine"                               \
      org.label-schema.url="InnovAnon-Inc.github.io/docker-wine"        \
      org.label-schema.vcs-ref=$VCS_REF                                 \
      org.label-schema.vcs-type="Git"                                   \
      org.label-schema.vcs-url="https://github.com/InnovAnon-Inc/docker-wine"

# Install required software

#RUN apt-fast install gnupg
#RUN wget -qO- https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
#RUN apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/

#RUN apt-add-repository ppa:ubuntu-wine/ppa

RUN dpkg --add-architecture i386
RUN apt-fast update
RUN apt-fast install libc6-i386 libstdc++6:i386
#RUN apt-fast install libc6-i386 libstdc++6:i386 libsm6:i386

#RUN apt-fast install --install-recommends winehq-stable
#RUN apt-fast install winehq-stable

# TODO figure out why it says wine server is already running
#      or try using devel version
#RUN apt-fast install --install-recommends winehq-devel
#RUN apt-fast install winehq-devel

RUN apt-fast install wine wine32
RUN apt-fast install --install-recommends wine wine32
RUN apt-fast install cabextract

# Create a non-privileged user
RUN useradd -ms /bin/bash wine-user
RUN usermod -a -G audio wine-user
RUN usermod -a -G video wine-user

COPY winetricks.sh .
RUN sed -i -e 's/sudo//g' -e '1a set -exu' winetricks.sh
RUN ./winetricks.sh
RUN rm -v winetricks.sh
RUN update_winetricks

#RUN initialize-graphics

USER wine-user
WORKDIR /home/wine-user

RUN WINEARCH=win32 wine wineboot

# wintricks
# TODO why does this use infinite memory?
RUN winetricks -q msls31
RUN winetricks -q ole32
RUN winetricks -q riched20
RUN winetricks -q riched30
RUN winetricks -q win7

USER root
WORKDIR /
# TODO uncomment
#RUN ./poobuntu-clean.sh

