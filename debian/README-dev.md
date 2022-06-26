Build howto
===========

```shell
docker-compose build \
  --build-arg DEBIAN_RELEASE=jessie-slim \
  --build-arg ASTERISK_VERSION=1.2.40 \
  --build-arg ASTERISK_ADDONS_VERSION=1.2.9 \
  ast \
&& docker-compose run --rm -i ast bash
```

jessie
export ASTERISK_VERSION=1.2.40 && export ASTERISK_ADDONS_VERSION=1.2.9
/build-asterisk.sh
asterisk -vvvdddTc

jessie
export ASTERISK_VERSION=1.4.44 && export ASTERISK_ADDONS_VERSION=1.4.13

jessie
export ASTERISK_VERSION=1.6.2.24 && export ASTERISK_ADDONS_VERSION=1.6.2.4

export ASTERISK_VERSION=1.8.32.3


