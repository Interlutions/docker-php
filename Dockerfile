FROM php

# Install PHP extensions
# TODO

# APCu
# TODO

# Disable xdebug by default and add a script to reactivate
# Just add a COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini.bak in your project
RUN docker-php-source extract && \
    pecl install xdebug-2.5.0 && \
    docker-php-ext-enable xdebug && \
    docker-php-source delete
COPY xdebug.sh /
RUN mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.bak

# Default configuration for fpm
COPY ./zz-fpm.conf /usr/local/etc/php-fpm.d/

# Base php ini
COPY ./docker-base.ini /usr/local/etc/php/conf.d/

# Download composer in the latest stable release
RUN curl -o composer-installer.php https://getcomposer.org/installer && \
    php composer-installer.php --quiet --install-dir="/usr/local/bin" && \
    ln -s /usr/local/bin/composer.phar /usr/local/bin/composer && \
    rm composer-installer.php
# Cache composer downloads in a volume
VOLUME /var/www/.composer


# Enable mailing via ssmtp
# TODO

# Install git+ssh (for composer install)
# TODO

# Install mysql client (for data-transfer operations)
# TODO

# Script to wait for db
COPY wait-for /usr/local/bin

# Install timezone change utils
# TODO

# Tools to change the uid on run
# TODO

# Install and configure fcron
RUN groupadd -r -g 109 fcron && \
    useradd -u 109 -r fcron -g fcron && \
    # TODO: Fetch build tools like wget and vim
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

# Modify entrypoint
COPY entrypoint-cron /usr/local/bin
COPY entrypoint-chuid /usr/local/bin
ENTRYPOINT ["entrypoint-chuid"]
CMD ["php-fpm"]
