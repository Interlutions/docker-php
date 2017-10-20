#!/bin/sh
# (De-)Activate xdebug for the currently running container

enable_xdebug () {
    if [ -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini ]; then
        echo "xdebug already enabled"
    else
        cp /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.bak /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
        cp /usr/local/etc/php/conf.d/xdebug.ini.bak /usr/local/etc/php/conf.d/xdebug.ini
        echo -e "xdebug \033[32menabled\033[0m "
    fi
}

disable_xdebug () {
    if [ -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini ]; then
        rm -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
        rm -f /usr/local/etc/php/conf.d/xdebug.ini
        echo -e "xdebug \033[31mdisabled\033[0m"
    else
        echo "xdebug already disabled"
    fi
}

case $1 in
    'on' | 'enable')
    enable_xdebug
    ;;

    'off' | 'disable')
    disable_xdebug
    ;;

    'toggle' | *)
    if [ -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini ]; then
        disable_xdebug
    else
        enable_xdebug
    fi
    ;;
esac

# Tell php-fpm to reload config
pkill -USR2 php-fpm
