FROM    qedadmin/base-debian:latest
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
            echo "Acquire::http::Proxy \"$HTTP_PROXY\";" >> /etc/apt/apt.conf.d/proxy.conf ; \
        fi \
        && \
        if [ ! -z "$HTTPS_PROXY" ]; then \
            echo "Acquire::https::Proxy \"$HTTPS_PROXY\";" >> /etc/apt/apt.conf.d/proxy.conf ; \
        fi \
        && echo "**** Adding Sury repos ****" \
        && echo "deb [trusted=yes] https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/sury.org.list \
        && \
        if [ ! -z "$HTTPS_PROXY" ]; then \
            curl -x $HTTPS_PROXY -sSk https://packages.sury.org/php/apt.gpg | apt-key add - ; \
        else \
            curl -sSk https://packages.sury.org/php/apt.gpg | apt-key add - ; \
        fi \
        \
        && echo "**** Install packages ****" \
        && apt-get update \
        && DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install -y \
        libaio1 \
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
        php5.6-readline php5.6-recode \
        php5.6-snmp php5.6-soap php5.6-sqlite3 php5.6-sybase \
        php5.6-tidy \
        php5.6-xml php5.6-xmlrpc php5.6-xsl \
        php5.6-zip \
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
        php7.2-readline php7.2-recode \
        php7.2-snmp php7.2-soap php7.2-sqlite3 php7.2-sybase \
        php7.2-tidy \
        php7.2-xml php7.2-xmlrpc php7.2-xsl \
        php7.2-zip \
        php-geoip \
        php-imagick \
        php-redis \
        php-xdebug \
        php-pear \
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
        && update-alternatives --set php /usr/bin/php7.2 \
        && update-alternatives --set php-config /usr/bin/php-config7.2 \
        && update-alternatives --set phpdbg /usr/bin/phpdbg7.2 \
        && update-alternatives --set phpize /usr/bin/phpize7.2 \
        && update-alternatives --set phar /usr/bin/phar7.2 \
        && \
        if [ ! -z "$HTTP_PROXY" ]; then \
            pear config-set http_proxy ${HTTP_PROXY}; \
        fi \
        && pecl channel-update pecl.php.net \
        && printf "instantclient,/usr/local/instantclient" | pecl -d php_suffix=7.2 install oci8 \
        && pecl uninstall -r oci8 \
        && pear -d php_suffix=7.2 install DB \
        && pear uninstall -r DB \
        && pear config-set http_proxy "" \
        && echo "extension=oci8.so" > /etc/php/7.2/mods-available/oci8.ini \
        && phpenmod -s ALL oci8 \
        && echo "**** Clean up packages ****" \
        && apt-get autoremove -y \
        && apt-get autoclean \
        && apt-get clean \
        && rm -rf \
       	/tmp/* \
       	/var/lib/apt/lists/* \
       	/var/tmp/* \
        && mkdir -p /run/php \
        && chown www-data:www-data /run/php


## root filesystem
COPY    root /


RUN     echo "**** Done ****"

#VOLUME  [ "/etc/php", "/run/php" ]

## init
ENTRYPOINT [ "/init" ]
