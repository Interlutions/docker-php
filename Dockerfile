FROM php:7.3-fpm-alpine

# Install PHP extensions
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS && \
    apk add --no-cache --virtual .gd-runtime-deps freetype libpng libjpeg-turbo && \
    apk add --no-cache --virtual .gd-build-deps freetype-dev libpng-dev libjpeg-turbo-dev && \
    apk add --no-cache --virtual .ext-runtime-deps libbz2 libmcrypt libxslt icu libzip-dev && \
    apk add --no-cache --virtual .ext-build-deps bzip2-dev libmcrypt-dev libxml2-dev libedit-dev libxslt-dev icu-dev sqlite-dev && \
    docker-php-ext-configure gd \
      --with-freetype-dir=/usr/include/ \
      --with-png-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/ && \
    NPROC=$(getconf _NPROCESSORS_ONLN) && \
    docker-php-ext-install -j${NPROC} bz2 dom exif fileinfo hash iconv intl opcache pcntl pdo pdo_mysql pdo_sqlite readline session simplexml xml xsl zip gd && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    pecl install apcu && \
    docker-php-ext-enable apcu && \
    apk del .gd-build-deps && \
    apk del .build-deps && \
    apk del .ext-build-deps && \
    rm -r /tmp/*

# Install Imagemagick
RUN apk add --no-cache imagemagick-dev imagemagick libtool autoconf gcc g++ make  \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apk del libtool autoconf gcc g++ make

# download composerin the latest stable release
RUN curl -o composer-installer.php https://getcomposer.org/installer && \
    php composer-installer.php --quiet --install-dir="/usr/local/bin" && \
    ln -s /usr/local/bin/composer.phar /usr/local/bin/composer && \
    rm composer-installer.php

# Install git+ssh (for composer install)
RUN apk add --no-cache git openssh-client rsync

# Install mysql client (for data-transfer operations)
RUN apk add --no-cache mysql-client

# Install PHP extension mysqli
RUN docker-php-ext-install mysqli

# Install timezone change utils
RUN apk add --no-cache tzdata

# Tools to change the uid on run
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories && \
    apk add --no-cache shadow su-exec

# Install and configure fcron
RUN groupadd -r -g 109 fcron && \
    useradd -u 109 -r fcron -g fcron && \
    apk add --no-cache --virtual .build-deps g++ make perl && \
    wget http://fcron.free.fr/archives/fcron-3.3.0.src.tar.gz && \
    tar xfz fcron-3.3.0.src.tar.gz  && \
    cd fcron-3.3.0  && \
    ./configure && \
    make && \
    make install && \
    apk del .build-deps && \
    rm -Rf fcron-3.3.0*z
ADD fcron.conf /usr/local/etc
ADD echomail /usr/local/bin
RUN chown root:fcron /usr/local/etc/fcron.conf && \
    chmod 644 /usr/local/etc/fcron.conf

# Default configuration for fpm
# Project-specific ini can be added with COPY ./php-ini-overrides.ini /usr/local/etc/php/conf.d/
COPY ./zz-fpm.conf /usr/local/etc/php-fpm.d/

# Base php ini
COPY ./docker-base.ini /usr/local/etc/php/conf.d/

# Disable xdebug by default and add a script to reactivate
# Just add a COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini.bak in your project
COPY xdebug.sh /
RUN mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.bak

# Cache composer downloads in a volume
VOLUME /var/www/.composer

# Script to wait for db
COPY wait-for /usr/local/bin

COPY entrypoint-cron /usr/local/bin
COPY entrypoint-chuid /usr/local/bin
ENTRYPOINT ["entrypoint-chuid"]
CMD ["php-fpm"]
