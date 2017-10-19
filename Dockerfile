FROM php:7.0-fpm-alpine

# Install PHP extensions
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS && \
    apk add --no-cache --virtual .gd-runtime-deps freetype libpng libjpeg-turbo && \
    apk add --no-cache --virtual .gd-build-deps freetype-dev libpng-dev libjpeg-turbo-dev && \
    apk add --no-cache --virtual .ext-runtime-deps libbz2 libmcrypt libxslt icu && \
    apk add --no-cache --virtual .ext-build-deps bzip2-dev libmcrypt-dev libxml2-dev libedit-dev libxslt-dev icu-dev sqlite-dev && \
    docker-php-ext-configure gd \
      --with-freetype-dir=/usr/include/ \
      --with-png-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/ && \
    NPROC=$(getconf _NPROCESSORS_ONLN) && \
    docker-php-ext-install -j${NPROC} bz2 dom exif fileinfo hash iconv mcrypt intl opcache pcntl pdo pdo_mysql pdo_sqlite readline session simplexml xml xsl zip gd && \
    pecl install xdebug-2.5.0 && \
    docker-php-ext-enable xdebug && \
    pecl install apcu && \
    docker-php-ext-enable apcu && \
    apk del .gd-build-deps && \
    apk del .build-deps && \
    apk del .ext-build-deps && \
    rm -r /tmp/*

# download composer as fallback if non is provided
RUN curl -o /usr/local/bin/composer.phar http://getcomposer.org/composer.phar && \
    chmod +x /usr/local/bin/composer.phar && \
    ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Install git+ssh (for composer install)
RUN apk add --no-cache git openssh-client rsync

# Default configuration for fpm
# Project-specific ini can be added with COPY ./php-ini-overrides.ini /usr/local/etc/php/conf.d/
COPY ./zz-fpm.conf /usr/local/etc/php-fpm.d/

# Disable xdebug by default and add a script to reactivate
# Just add a COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini.bak in your project
COPY xdebug.sh /
RUN mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.bak

# Tools to change the uid on run
RUN echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories && \
    apk add --no-cache shadow
COPY entrypoint-chuid /usr/local/bin
ENTRYPOINT ["entrypoint-chuid"]
CMD ["php-fpm"]