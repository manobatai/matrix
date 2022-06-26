#!/bin/bash

set -exo pipefail

PROGNAME="$(basename $0)"

if test -z ${ASTERISK_VERSION}; then
    echo "${PROGNAME}: ASTERISK_VERSION required" >&2
    exit 1
fi

# 1.5 jobs per core works out okay
: ${JOBS:=$(( $(nproc) + $(nproc) / 2 ))}

. /etc/os-release

# VERSION="8 (jessie)"
# VERSION="9 (stretch)"
# VERSION="10 (buster)"
# VERSION="11 (bullseye)"
DEBIAN_VERSION="$VERSION"

useradd --system asterisk

export DEBIAN_FRONTEND=noninteractive

apt-get update -qq &> /dev/null

apt-get install -yqq --no-install-recommends --no-install-suggests \
    autoconf \
    binutils-dev \
    build-essential \
    ca-certificates \
    curl \
    file \
    less \
    libasound2-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libgsm1-dev \
    libncurses5-dev \
    libpopt-dev \
    libresample1-dev \
    libspandsp-dev \
    libspeex-dev \
    libspeexdsp-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    unixodbc \
    unixodbc-bin \
    unixodbc-dev \
    uuid \
    uuid-dev \
    xmlstarlet

if [ "$DEBIAN_VERSION" = "8 (jessie)" ]; then
    apt-get install -yqq --no-install-recommends --no-install-suggests \
        libmysqlclient-dev \
        &> /dev/null
else
    apt-get install -yqq --no-install-recommends --no-install-suggests \
        libmariadb-dev \
        &> /dev/null
fi

apt-get purge -yqq --auto-remove &> /dev/null

mkdir -p /usr/src/asterisk \
         /usr/src/asterisk/addons \
         /etc/asterisk \
         /var/spool/asterisk/fax

cd /usr/src/asterisk
curl -vsL http://downloads.asterisk.org/pub/telephony/asterisk/old-releases/asterisk-${ASTERISK_VERSION}.tar.gz | tar --strip-components 1 -xz

if [ "$ASTERISK_ADDONS_VERSION" != "" ]; then
    cd /usr/src/asterisk/addons
    curl -vsL http://downloads.asterisk.org/pub/telephony/asterisk/old-releases/asterisk-addons-${ASTERISK_ADDONS_VERSION}.tar.gz | tar --strip-components 1 -xz
fi

if [[ $ASTERISK_VERSION =~ ^1\.2\.+ ]]; then
    # cannot get chan_alsa and codec_speex compiled with 1.2 and jessie
    apt-get purge -yqq \
        libasound2 \
        libasound2-data \
        libasound2-dev \
        libspeex-dev \
        libspeex1 \
        libspeexdsp-dev \
        libspeexdsp1 \
        &> /dev/null
    apt-get purge -yqq --auto-remove &> /dev/null

    cd /usr/src/asterisk

    make -j ${JOBS} all > /dev/null || make -j ${JOBS} all
    make install
    make samples

    if [ "$ASTERISK_ADDONS_VERSION" != "" ]; then
        cd /usr/src/asterisk/addons

        make -j ${JOBS} all
        make -j ${JOBS} all > /dev/null || make -j ${JOBS} all
        make install
    fi
else
    cd /usr/src/asterisk

    if [[ $ASTERISK_VERSION =~ ^1\.[68]\.+ ]]; then
        ./configure &> /dev/null
    else
        ./configure --with-resample \
                    --with-pjproject-bundled \
                    --with-jansson-bundled \
                    &> /dev/null
    fi

    if [[ $ASTERISK_VERSION =~ ^(1\.8\.+|1[0-9]\.+) ]]; then
        make menuselect/menuselect menuselect-tree menuselect.makeopts

        # disable BUILD_NATIVE to avoid platform issues
        menuselect/menuselect --disable BUILD_NATIVE menuselect.makeopts

        # enable good things
        menuselect/menuselect --enable BETTER_BACKTRACES menuselect.makeopts

        # enable ooh323
        menuselect/menuselect --enable chan_ooh323 menuselect.makeopts

        # codecs
        # menuselect/menuselect --enable codec_opus menuselect.makeopts
        # menuselect/menuselect --enable codec_silk menuselect.makeopts

        # # download more sounds
        # for i in CORE-SOUNDS-EN MOH-OPSOUND EXTRA-SOUNDS-EN; do
        #   for j in ULAW ALAW G722 GSM SLN16; do
        #     menuselect/menuselect --enable $i-$j menuselect.makeopts
        #   done
        # done

        # we don't need any sounds in docker, they will be mounted as volume
        menuselect/menuselect --disable-category MENUSELECT_CORE_SOUNDS menuselect.makeopts
        menuselect/menuselect --disable-category MENUSELECT_MOH menuselect.makeopts
        menuselect/menuselect --disable-category MENUSELECT_EXTRA_SOUNDS menuselect.makeopts
    fi

    make -j ${JOBS} all > /dev/null || make -j ${JOBS} all
    make install
    make samples

    if [ "$ASTERISK_ADDONS_VERSION" != "" ]; then
        cd /usr/src/asterisk/addons
        ./configure
        make -j ${JOBS} all > /dev/null || make -j ${JOBS} all
        make install
    fi
fi


chown -R asterisk:asterisk /etc/asterisk \
                           /var/*/asterisk \
                           /usr/*/asterisk

chmod -R 750 /var/spool/asterisk

cd /
rm -rf /usr/src/asterisk \
       /usr/src/codecs

# remove *-dev packages
DEVPACKAGES="$(dpkg -l | grep '\-dev' | awk '{print $2}' | xargs)"
DEBIAN_FRONTEND=noninteractive apt-get --yes purge \
    autoconf \
    build-essential \
    bzip2 \
    cpp \
    m4 \
    make \
    patch \
    perl \
    perl-modules \
    pkg-config \
    xz-utils \
    $DEVPACKAGES \
    &> /dev/null
rm -rf /var/lib/apt/lists/*

exec rm -f /build-asterisk.sh
