FROM php

###########
### PHP ###
###########
# ext-bz2
#RUN apt-get update &&\
#    apt-get install -y --no-install-recommends libbz2-dev &&\
#    docker-php-ext-install -j$(nproc) bz2 &&\
#    apt-get purge -y libbz2-dev &&\
#    rm -r /var/lib/apt/lists/*
#

# ext-intl
#RUN docker-php-ext-install -j$(nproc) intl

# ext-MySQL
RUN docker-php-ext-install -j$(nproc) pdo_mysql

# ext-zip
#RUN docker-php-ext-install -j$(nproc) zip

## Install GD
#RUN xapt-get update &&\
#    apt-get install -y --no-install-recommends \
#        icu-devtools \
#        libbsd-dev \
#        libbz2-dev \
#        libedit-dev \
#        libfreetype6 \
#        libfreetype6-dev \
#        libicu-dev \
#        libicu52 \
#        libjpeg62-turbo \
#        libjpeg62-turbo-dev \
#        libmcrypt-dev \
#        libmcrypt4 \
#        libpng12-0 \
#        libpng12-dev \
#        libtinfo-dev \
#        libxml2-dev \
#        libxslt1-dev \
#        libxslt1.1 \
#        zlib1g-dev \
#        libjpeg-turbo-progs \
#        optipng \
#    && \
#    docker-php-ext-configure gd \
#        --with-freetype-dir=/usr/include/ \
#        --with-png-dir=/usr/include/ \
#        --with-jpeg-dir=/usr/include/ \
#    && \
#    docker-php-ext-install -j$(nproc) \
#	    bz2 \
#        dom \
#        hash \
#        iconv \
#        mcrypt \
#        intl \
#        pcntl \
#        pdo_mysql \
#        readline \
#        session \
#        simplexml \
#        xml \
#        xsl \
#        zip \
#        gd \
#    && \
#    apt-get purge -y \
#        icu-devtools libbsd-dev libbz2-dev libedit-dev libfreetype6-dev \
#        libicu-dev libjpeg62-turbo-dev libmcrypt-dev \
#        libpng12-dev libtinfo-dev libxml2-dev \
#        libxslt1-dev zlib1g-dev \
#    rm -r /var/lib/apt/lists/*

# Disable xdebug by default and add a script to reactivate
# Just add a COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini.bak in your project
RUN docker-php-source extract && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    docker-php-source delete
RUN apt-get update && \
    apt-get install -y --no-install-recommends procps &&\
    rm -r /var/lib/apt/lists/*
COPY xdebug.sh /
RUN mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.bak

# Default configuration for fpm
COPY ./zz-fpm.conf /usr/local/etc/php-fpm.d/

# Base php ini
COPY ./docker-base.ini /usr/local/etc/php/conf.d/

################
### COMPOSER ###
################
# Download composer in the latest stable release
RUN curl -o composer-installer.php https://getcomposer.org/installer && \
    php composer-installer.php --quiet --install-dir="/usr/local/bin" && \
    ln -s /usr/local/bin/composer.phar /usr/local/bin/composer && \
    rm composer-installer.php
# Cache composer downloads in a volume
VOLUME /var/www/.composer
# Install git+ssh (for composer install)
# TODO

###############
### MAILING ###
###############
# Enable mailing via ssmtp
# TODO

###################
### MySQL Tools ###
###################
# Install mysql client (for data-transfer operations)
# TODO
# Script to wait for db
COPY wait-for /usr/local/bin

###################
### Linux hacks ###
###################
# Install timezone change utils
# TODO

# Tools to change the uid on run
# TODO

############
### CRON ###
############
# Install and configure fcron
# TODO
#RUN groupadd -r -g 109 fcron && \
#    useradd -u 109 -r fcron -g fcron && \
#    # TODO: Fetch build tools like wget and vim
#    wget http://fcron.free.fr/archives/fcron-3.3.0.src.tar.gz && \
#    tar xfz fcron-3.3.0.src.tar.gz  && \
#    cd fcron-3.3.0  && \
#    ./configure && \
#    make && \
#    make install && \
#    apk del .build-deps && \
#    rm -Rf fcron-3.3.0*z
#ADD fcron.conf /usr/local/etc
#ADD echomail /usr/local/bin
#RUN chown root:fcron /usr/local/etc/fcron.conf && \
#    chmod 644 /usr/local/etc/fcron.conf

###############
### STARTUP ###
###############
# Modify entrypoint
COPY entrypoint-cron /usr/local/bin
COPY entrypoint-chuid /usr/local/bin
ENTRYPOINT ["entrypoint-chuid"]
CMD ["php-fpm"]
