FROM php:7.4-apache-buster

ENV BUILD_DEPS \
        cron \
        g++ \
        gettext \
        libicu-dev \
        openssl \
        libc-client-dev \
        libkrb5-dev \
        libxml2-dev \
        libfreetype6-dev \
        libgd-dev \
        libmcrypt-dev \
        bzip2 \
        libbz2-dev \
        libtidy-dev \
        libcurl4-openssl-dev \
        libz-dev \
        libmemcached-dev \
        libxslt-dev \
        libgmp-dev \
        libldap2-dev \
        python3 \
        python3-pycurl \
        unzip \
        wget \
        git

RUN apt-get update \
    && apt-get install --yes --no-install-recommends $BUILD_DEPS \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install pdo pdo_mysql curl gmp imap json ldap mbstring simplexml gd \
    && yes '' | pecl install -f mailparse mcrypt-1.0.1 \
    && docker-php-ext-enable mcrypt \
    && a2enmod rewrite \
    && a2enmod headers \
    && a2enmod remoteip  \
    && apt-get -y autoclean && apt-get -y autoremove && apt-get -y clean && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /etc/cron.{hourly,daily,weekly,monthly} \
    && echo "extension=mailparse.so" > /usr/local/etc/php/conf.d/docker-php-ext-mailparse.ini \
    && sed -i 's/^LogFormat/#&/' /etc/apache2/apache2.conf \
    && echo "[PHP]" >> /usr/local/etc/php/php.ini \
    && echo "expose_php=Off" >> /usr/local/etc/php/php.ini \
    && echo "ServerTokens Prod" >> /etc/apache2/conf-enabled/security.conf \
    && echo "ServerSignature Off" >> /etc/apache2/conf-enabled/security.conf \
    && ln -sf /proc/self/fd/1 /var/log/apache2/access.log \
    && ln -sf /proc/self/fd/1 /var/log/apache2/error.log \
    && mkdir /docker-entrypoint-initweb.d
     
ADD entrypoint.sh /entrypoint.sh

VOLUME /var/www/app
WORKDIR /var/www/app
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK CMD curl --silent --fail localhost:80 || exit 1
