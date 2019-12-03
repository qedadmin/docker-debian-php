Custom PHP image

## Usage

To get started.

### docker

```
docker create \
  --name=debian-php \
  -v <path to php config>:/etc/php \
  -v <path to php run>:/run/php \
  --privileged
  --restart unless-stopped \
  qedadmin/debian-php
```

## Parameters


| Parameter | Function |
| :---- | --- |
| `-v /etc/php` | Location of PHP config files |
| `-v /run/php` | Location of PHP run files |
