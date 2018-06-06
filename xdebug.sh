#!/bin/sh
# (De-)Activate xdebug for the currently running container

enable_xdebug () {
    cp /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.bak /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    cp /usr/local/etc/php/conf.d/xdebug.ini.bak /usr/local/etc/php/conf.d/xdebug.ini
}

disable_xdebug () {
    rm -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    rm -f /usr/local/etc/php/conf.d/xdebug.ini
}

show_status() {
    if [ -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini ]; then
        echo "xdebug is enabled"
    else
        echo "xdebug is disabled"
    fi
}

case $1 in
    '1' | 'on' | 'enable')
        enable_xdebug
        show_status
        ;;

    '0' | 'off' | 'disable')
        disable_xdebug
        show_status
        ;;

    'toggle')
        if [ -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini ]; then
            disable_xdebug
        else
            enable_xdebug
        fi
        show_status
        ;;

    'status' | *)
        show_status
        ;;
esac

# Tell php-fpm to reload config
pkill -USR2 php-fpm
