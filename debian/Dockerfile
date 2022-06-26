# vim:set ft=dockerfile:
ARG DEBIAN_RELEASE
FROM debian:$DEBIAN_RELEASE

LABEL maintainer="Andrius Kairiukstis <k@andrius.mobi>"

ARG ASTERISK_VERSION
# Specify asterisk addons version (asterisk 1.2 to 1.8)
ARG ASTERISK_ADDONS_VERSION

ARG BUILD_SCRIPT
COPY $BUILD_SCRIPT /build-asterisk.sh
RUN /build-asterisk.sh

EXPOSE 5060/udp 5060/tcp
VOLUME /var/lib/asterisk/sounds /var/lib/asterisk/keys /var/lib/asterisk/phoneprov /var/spool/asterisk /var/log/asterisk

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/asterisk", "-vvvdddf", "-T", "-W", "-U", "asterisk", "-p"]
