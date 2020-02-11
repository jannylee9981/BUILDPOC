FROM ubuntu:14.04
MAINTAINER  hwanseok.kim hwanseok.kim@gmail.com


# ADD User
ARG UID=8100
ARG GID=8100
ARG UNAME=vc.integrator
RUN groupadd -g $GID -o $UNAME
RUN mkdir -p /data001
RUN useradd -m -u $UID -g $GID -o -s /bin/bash -d /data001/$UNAME $UNAME
RUN echo 'vc.integrator ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN usermod -G sudo -a vc.integrator


# Common Tools
RUN apt-get update -y \
    && apt-get install software-properties-common -y \
    && add-apt-repository ppa:git-core/ppa -y \
    && apt-get update -y \
    && apt-get upgrade -y

# ADD sudo 
RUN apt-get update -y \
	&& echo "Y" | apt-get install sudo -y \
    && echo "Y" | apt-get install ssh -y

RUN apt-get install -y \
    byobu \
    wget \
    make \
    vim \
    git \
    curl \
    cpio \
    unzip \
    sshpass \
    zip \  
    gawk \
    wget \
    rsync \
    gcc \
    g++

# Java
RUN add-apt-repository -y ppa:openjdk-r/ppa \
    && apt-get update && sudo apt-get install -y openjdk-8-jdk
    
# Repo 
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > repo \
    && chmod 755 repo \
    && mv repo /usr/bin/repo


# python 2.7
RUN apt-get install -y \
    python2.7 \
    python2.7-dev \
    python-pip \
    python-mock \
    python-nose \
    python-coverage \
    pylint \
	python-zmq


# GIT-LFS
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
    && apt-get install git-lfs \
    && git-lfs install \
    && git config --system lfs.url http://art.lge.com/vc/api/lfs/lfs.ivi \
    && git lfs env


# Qualcomm Library
# lib32bz2-1.0 -> libbz2-1.0:i386
# lib32bz2-dev -> libbz2-dev:i386
RUN apt-get install -y \
    git-core \
    diffstat \
    texinfo \
    build-essential \
    chrpath \
    xterm \
    subversion \
    cvs \
    dos2unix \
    lzop \
    gcc-multilib \
    g++-multilib \
    libglib2.0-dev \
    lib32gcc1 \
    libc6-i386 \
    lib32z1 \
    lib32stdc++6 \
    lib32ncurses5 \
    lib32gomp1 \
    lib32z1-dev \
    flex \
    libssl-dev \
    python-dev \
    xutils-dev \
    gettext \
    && dpkg --add-architecture i386 \
    && apt-get update -y \
    && apt-get install -y libbz2-1.0:i386 \
    libbz2-dev:i386 \
    automake \
    autoconf \
    libsdl1.2-dev \
    libtool


#GDB Coredump Analysis
RUN apt-get install -y \
    gdb-multiarch \
    p7zip-full


#Zero-SW Build Add Package
RUN apt-get install -y heirloom-mailx


RUN apt-get install -y \
    pigz \
    lbzip2 \
    && cd /bin \
    && mv gzip gzip_org \
    && mv gunzip gunzip_org \
    && mv bzip2 bzip2_org \
    && mv bzcat bzcat_org \
    && mv bunzip2 bunzip2_org \
    && ln -s /usr/bin/pigz gzip \
    && ln -s /usr/bin/pigz gunzip \
    && ln -s /usr/bin/lbzip2 bzip2 \
    && ln -s /usr/bin/lbzip2 bunzip2 \
    && ln -s /usr/bin/lbzip2 bzcat \
    && ln -sf /bin/bash /bin/sh 


# TZ_toolchain 
#COPY toolchain/ /etc
ADD tz_toolchain.zip /etc
RUN cd /etc \
    && unzip tz_toolchain.zip \
    && rm -rf tz_toolchain.zip


RUN ln -s /etc/toolchain/pkg /pkg \
    && ln -s /etc/toolchain/prj /prj


# usb update -> meta data signing work
ADD wolfssl-3.12.0.zip /etc
ADD key_gen /etc
ADD privatekey.p8 /etc
RUN cd /etc \
    && unzip wolfssl-3.12.0.zip \
    && rm -rf wolfssl-3.12.0.zip

RUN cd /etc/wolfssl-3.12.0 \
    && ./configure --enable-certgen --enable-certreq --enable-certext --enable-psk=yes --enable-pwdbased CFLAGS='-DWOLFSSL_PUB_PEM_TO_DER -DATOMIC_USER -DHAVE_AESGCM -DHAVE_ECC -DHAVE_NULL_CIPHER -DWOLFSSL_STATIC_PSK -DWOLFSSL_CERT_GEN -DWOLFSSL_CERT_REQ -DWOLFSSL_KEY_GEN -DOPENSSL_EXTRA -DWOLFSSL_ALWAYS_VERIFY_CB -DNO_SESSION_CACHE' CPPFLAGS='-DATOMIC_USER -DHAVE_AESGCM -DHAVE_ECC -DHAVE_NULL_CIPHER -DWOLFSSL_STATIC_PSK -DWOLFSSL_CERT_GEN -DWOLFSSL_CERT_REQ -DWOLFSSL_KEY_GEN -DOPENSSL_EXTRA -DWOLFSSL_ALWAYS_VERIFY_CB -DNO_SESSION_CACHE -DWOLFSSL_PUB_PEM_TO_DER -DWC_RSA_PSS' \
    && make install \
    && ldconfig -v \
    && mv ../key_gen . \
    && mv ../privatekey.p8 .\
    && chmod 755 key_gen \
    && ./key_gen


ADD protobuf-java-3.11.2.tar.gz /etc
RUN cd /etc/protobuf-3.11.2 \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make check \
    && make install \
    && ldconfig

RUN apt-get autoremove \
    && apt-get clean


CMD ["/bin/bash"]