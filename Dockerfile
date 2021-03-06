ARG     HAPROXY_TAG=2.3
ARG     MYSQL_TAG=5.7
ARG     BASE_TAG=latest

FROM    haproxy:${HAPROXY_TAG} AS build_haproxy
ARG     MYSQL_TAG
ARG     BASE_TAG
ARG     HTTP_PROXY
ARG     HTTPS_PROXY
ARG     BUILD_DATE
ARG     VCS_REF
ARG     BUILD_VERSION

FROM    mysql:${MYSQL_TAG} AS build_mysql
ARG     BASE_TAG
ARG     HTTP_PROXY
ARG     HTTPS_PROXY
ARG     BUILD_DATE
ARG     VCS_REF
ARG     BUILD_VERSION

FROM    qedadmin/base-debian:${BASE_TAG}
ARG     HTTP_PROXY
ARG     HTTPS_PROXY

ARG     BUILD_DATE
ARG     VCS_REF
ARG     BUILD_VERSION

ARG     INSTANTCLIENT_VERSION="12.2.0.1.0"

LABEL   org.label-schema.schema-version="1.0" \
        org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.version=$BUILD_VERSION

ADD     https://github.com/qedadmin/docker-debian-php/raw/master/instantclient/instantclient-basic-linux.x64-${INSTANTCLIENT_VERSION}.zip /tmp/
ADD     https://github.com/qedadmin/docker-debian-php/raw/master/instantclient/instantclient-sdk-linux.x64-${INSTANTCLIENT_VERSION}.zip /tmp/
ADD     https://github.com/qedadmin/docker-debian-php/raw/master/instantclient/instantclient-sqlplus-linux.x64-${INSTANTCLIENT_VERSION}.zip /tmp/
ADD     https://github.com/qedadmin/docker-debian-php/raw/master/instantclient/sqlnet.ora /tmp/
ADD     http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb /tmp/
ADD     https://www.percona.com/downloads/Percona-XtraBackup-LATEST/Percona-XtraBackup-8.0.14/binary/debian/buster/x86_64/percona-xtrabackup-80_8.0.14-1.buster_amd64.deb  /tmp/percona-xtrabackup.deb

## Install packages
RUN     \
        unzip /tmp/instantclient-basic-linux.x64-${INSTANTCLIENT_VERSION}.zip -d /usr/local/ \
        && unzip /tmp/instantclient-sdk-linux.x64-${INSTANTCLIENT_VERSION}.zip -d /usr/local/ \
        && unzip /tmp/instantclient-sqlplus-linux.x64-${INSTANTCLIENT_VERSION}.zip -d /usr/local/ \
        && ln -s /usr/local/instantclient_12_2 /usr/local/instantclient \
        && cp /tmp/sqlnet.ora /usr/local/instantclient/ \
        && ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so \
        && ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus \
        && echo /usr/local/instantclient/ > /etc/ld.so.conf.d/instantclient.conf \
        && ldconfig \
        && \
        if [ ! -z "$HTTP_PROXY" ]; then \
            echo "proxy=$HTTP_PROXY" >> ~/.curlrc ; \
            echo "noproxy=127.0.0.1,localhost" >> ~/.curlrc ; \
            echo "insecure" >> ~/.curlrc ; \
        fi \
        && \
        if [ ! -z "$HTTP_PROXY" ]; then \
            echo "Acquire::http::Proxy \"$HTTP_PROXY\";" >> /etc/apt/apt.conf.d/proxy.conf ; \
        fi \
        && \
        if [ ! -z "$HTTPS_PROXY" ]; then \
            echo "Acquire::https::Proxy \"$HTTPS_PROXY\";" >> /etc/apt/apt.conf.d/proxy.conf ; \
            echo "Acquire::https::Verify-Peer \"false\";" >> /etc/apt/apt.conf.d/proxy.conf ; \
        fi \
        && echo "**** Adding Sury repos ****" \
        && echo "deb [trusted=yes] https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/sury.org.list \
        && curl -sSk https://packages.sury.org/php/apt.gpg | apt-key add - \
        && echo "**** Adding nodesource repos ****" \
        && echo "Package: nodejs" >> /etc/apt/preferences.d/nodejs.pref \
        && echo "Pin: version 6.*" >> /etc/apt/preferences.d/nodejs.pref \
        && echo "Pin-Priority: 999" >> /etc/apt/preferences.d/nodejs.pref \
        && curl -sLk https://deb.nodesource.com/setup_6.x | bash - \
        && echo "**** Install packages ****" \
        && apt-get update \
        && DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install -y \
        libaio1 \
        libc6-dev \
        liblua5.3-dev \
        libpcre2-dev \
        libssl-dev \
        zlib1g-dev \
        php5.6 \
        php5.6-bcmath php5.6-bz2 \
        php5.6-cli php5.6-common php5.6-curl \
        php5.6-dba php5.6-dev \
        php5.6-enchant \
        php5.6-fpm \
        php5.6-gd php5.6-gmp \
        php5.6-imap php5.6-interbase php5.6-intl \
        php5.6-json \
        php5.6-ldap \
        php5.6-mbstring php5.6-mcrypt php5.6-mysql \
        php5.6-odbc php5.6-opcache \
        php5.6-pgsql php5.6-phpdbg php5.6-pspell \
        php5.6-readline \
        php5.6-snmp php5.6-soap php5.6-sqlite3 php5.6-sybase \
        php5.6-tidy \
        php5.6-xml php5.6-xmlrpc php5.6-xsl \
        php5.6-zip \
        php7.0 \
        php7.0-bcmath php7.0-bz2 php7.0-cli php7.0-common php7.0-curl \
        php7.0-dba php7.0-dev \
        php7.0-enchant \
        php7.0-fpm \
        php7.0-gd php7.0-gmp \
        php7.0-imap php7.0-interbase php7.0-intl \
        php7.0-json \
        php7.0-ldap \
        php7.0-mbstring php7.0-mysql \
        php7.0-odbc php7.0-opcache \
        php7.0-pgsql php7.0-phpdbg php7.0-pspell \
        php7.0-readline \
        php7.0-snmp php7.0-soap php7.0-sqlite3 php7.0-sybase \
        php7.0-tidy \
        php7.0-xml php7.0-xmlrpc php7.0-xsl \
        php7.0-zip \
        php7.2 \
        php7.2-bcmath php7.2-bz2 php7.2-cli php7.2-common php7.2-curl \
        php7.2-dba php7.2-dev \
        php7.2-enchant \
        php7.2-fpm \
        php7.2-gd php7.2-gmp \
        php7.2-imap php7.2-interbase php7.2-intl \
        php7.2-json \
        php7.2-ldap \
        php7.2-mbstring php7.2-mysql \
        php7.2-odbc php7.2-opcache \
        php7.2-pgsql php7.2-phpdbg php7.2-pspell \
        php7.2-readline \
        php7.2-snmp php7.2-soap php7.2-sqlite3 php7.2-sybase \
        php7.2-tidy \
        php7.2-xml php7.2-xmlrpc php7.2-xsl \
        php7.2-zip \
        php7.4 \
        php7.4-bcmath php7.4-bz2 php7.4-cli php7.4-common php7.4-curl \
        php7.4-dba php7.4-dev \
        php7.4-enchant \
        php7.4-fpm \
        php7.4-gd php7.4-gmp \
        php7.4-imap php7.4-interbase php7.4-intl \
        php7.4-json \
        php7.4-ldap \
        php7.4-mbstring php7.4-mysql \
        php7.4-odbc php7.4-opcache \
        php7.4-pgsql php7.4-phpdbg php7.4-pspell \
        php7.4-readline \
        php7.4-snmp php7.4-soap php7.4-sqlite3 php7.4-sybase \
        php7.4-tidy \
        php7.4-xml php7.4-xmlrpc php7.4-xsl \
        php7.4-zip \
        php8.0 \
        php8.0-bcmath php8.0-bz2 php8.0-cli php8.0-common php8.0-curl \
        php8.0-dba php8.0-dev \
        php8.0-enchant \
        php8.0-fpm \
        php8.0-gd php8.0-gmp \
        php8.0-imap php8.0-interbase php8.0-intl \
        php8.0-ldap \
        php8.0-mbstring php8.0-mysql \
        php8.0-odbc php8.0-opcache \
        php8.0-pgsql php8.0-phpdbg php8.0-pspell \
        php8.0-readline \
        php8.0-snmp php8.0-soap php8.0-sqlite3 php8.0-sybase \
        php8.0-tidy \
        php8.0-xml php8.0-xsl \
        php8.0-zip \
        php-geoip-all-dev \
        php-imagick-all-dev \
        php-redis-all-dev \
        php-xdebug-all-dev \
        php-pear \
        php-json \
        multiarch-support \
        libncurses5 \
        nodejs \
        redis-server \
        libdbd-mysql-perl \
        libcurl4-openssl-dev \
        libev4 \
        libfcgi0ldbl \
        && update-alternatives --set php /usr/bin/php5.6 \
        && update-alternatives --set php-config /usr/bin/php-config5.6 \
        && update-alternatives --set phpdbg /usr/bin/phpdbg5.6 \
        && update-alternatives --set phpize /usr/bin/phpize5.6 \
        && update-alternatives --set phar /usr/bin/phar5.6 \
        && \
        if [ ! -z "$HTTP_PROXY" ]; then \
            pear config-set http_proxy ${HTTP_PROXY}; \
        fi \
        && printf "instantclient,/usr/local/instantclient" | pecl -d php_suffix=5.6 install oci8-2.0.12 \
        && pecl uninstall -r oci8 \
        && pear -d php_suffix=5.6 install DB \
        && pear uninstall -r DB \
        && pear config-set http_proxy "" \
        && echo "extension=oci8.so" > /etc/php/5.6/mods-available/oci8.ini \
        \
        && update-alternatives --set php /usr/bin/php7.0 \
        && update-alternatives --set php-config /usr/bin/php-config7.0 \
        && update-alternatives --set phpdbg /usr/bin/phpdbg7.0 \
        && update-alternatives --set phpize /usr/bin/phpize7.0 \
        && update-alternatives --set phar /usr/bin/phar7.0 \
        && \
        if [ ! -z "$HTTP_PROXY" ]; then \
            pear config-set http_proxy ${HTTP_PROXY}; \
        fi \
        && printf "instantclient,/usr/local/instantclient" | pecl -d php_suffix=7.0 install oci8-2.2.0 \
        && pecl uninstall -r oci8 \
        && pear -d php_suffix=7.0 install DB \
        && pear uninstall -r DB \
        && pear config-set http_proxy "" \
        && echo "extension=oci8.so" > /etc/php/7.0/mods-available/oci8.ini \
        \
        && update-alternatives --set php /usr/bin/php7.2 \
        && update-alternatives --set php-config /usr/bin/php-config7.2 \
        && update-alternatives --set phpdbg /usr/bin/phpdbg7.2 \
        && update-alternatives --set phpize /usr/bin/phpize7.2 \
        && update-alternatives --set phar /usr/bin/phar7.2 \
        && \
        if [ ! -z "$HTTP_PROXY" ]; then \
            pear config-set http_proxy ${HTTP_PROXY}; \
        fi \
        && printf "instantclient,/usr/local/instantclient" | pecl -d php_suffix=7.2 install oci8-2.2.0 \
        && pecl uninstall -r oci8 \
        && pear -d php_suffix=7.2 install DB \
        && pear uninstall -r DB \
        && pear config-set http_proxy "" \
        && echo "extension=oci8.so" > /etc/php/7.2/mods-available/oci8.ini \
        \
        && update-alternatives --set php /usr/bin/php7.4 \
        && update-alternatives --set php-config /usr/bin/php-config7.4 \
        && update-alternatives --set phpdbg /usr/bin/phpdbg7.4 \
        && update-alternatives --set phpize /usr/bin/phpize7.4 \
        && update-alternatives --set phar /usr/bin/phar7.4 \
        && \
        if [ ! -z "$HTTP_PROXY" ]; then \
            pear config-set http_proxy ${HTTP_PROXY}; \
        fi \
        && pecl channel-update pecl.php.net \
        && printf "instantclient,/usr/local/instantclient" | pecl -d php_suffix=7.4 install oci8-2.2.0 \
        && pecl uninstall -r oci8 \
        && pear -d php_suffix=7.4 install DB \
        && pear uninstall -r DB \
        && pear config-set http_proxy "" \
        && echo "extension=oci8.so" > /etc/php/7.4/mods-available/oci8.ini \
        \
        && update-alternatives --set php /usr/bin/php8.0 \
        && update-alternatives --set php-config /usr/bin/php-config8.0 \
        && update-alternatives --set phpdbg /usr/bin/phpdbg8.0 \
        && update-alternatives --set phpize /usr/bin/phpize8.0 \
        && update-alternatives --set phar /usr/bin/phar8.0 \
        && \
        if [ ! -z "$HTTP_PROXY" ]; then \
            pear config-set http_proxy ${HTTP_PROXY}; \
        fi \
        && pecl channel-update pecl.php.net \
        && printf "instantclient,/usr/local/instantclient" | pecl -d php_suffix=8.0 install oci8-3.0.0 \
        && pecl uninstall -r oci8 \
        && pear -d php_suffix=8.0 install DB \
        && pear uninstall -r DB \
        && pear config-set http_proxy "" \
        && echo "extension=oci8.so" > /etc/php/8.0/mods-available/oci8.ini \
        \
        && phpenmod -s ALL oci8 \
        && dpkg -i /tmp/libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb \
        && dpkg -i /tmp/percona-xtrabackup.deb \
        && echo "**** Clean up packages ****" \
        && apt-get autoremove -y \
        && apt-get autoclean \
        && apt-get clean \
        && ln -s /usr/bin/php5.6 /usr/bin/php5 \
        && ln -s /usr/bin/php7.4 /usr/bin/php7 \
        && ln -s /usr/bin/php8.0 /usr/bin/php8 \
        && rm -rf \
       	/tmp/* \
       	/var/lib/apt/lists/* \
       	/var/tmp/* \
       	&& rm -f /etc/php/5.6/fpm/pool.d/*.conf \
       	/etc/php/7.0/fpm/pool.d/*.conf \
       	/etc/php/7.1/fpm/pool.d/*.conf \
       	/etc/php/7.2/fpm/pool.d/*.conf \
       	/etc/php/7.3/fpm/pool.d/*.conf \
       	/etc/php/7.4/fpm/pool.d/*.conf \
       	/etc/php/8.0/fpm/pool.d/*.conf \
        && mkdir -p /run/php \
        && mkdir -p /etc/haproxy \
        && mkdir -p /var/run/mysqld \
        && mkdir -p /var/run/redis \
        && chown www-data:www-data /run/php

## MySQL
COPY    --from=build_mysql /usr/bin/mysql /usr/bin/

## HAProxy
COPY    --from=build_haproxy /usr/local/sbin/haproxy /usr/sbin/
COPY    --from=build_haproxy /usr/local/etc/haproxy/errors /etc/haproxy/errors

## root filesystem
COPY    root /


RUN     echo "**** Done ****"

#VOLUME  [ "/etc/php", "/run/php" ]

## init
ENTRYPOINT [ "/init" ]
