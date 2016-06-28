#!/bin/bash

PATH=/sbin:/usr/local/sbin:/usr/sbin:/usr/bin:/bin

# ------ Config -----
CURDIR=$(pwd)
chmod -R 700 $CURDIR/shell
source $CURDIR/shell/config.sh

if [ -f /etc/init.d/nginx ];then
    /etc/init.d/nginx stop
    rm -f /etc/init.d/nginx
fi
if [ -f /etc/init.d/php-fpm ];then
    /etc/init.d/php-fpm stop
    rm -f /etc/init.d/php-fpm
fi
if [ -f /etc/init.d/mysqld ];then
    /etc/init.d/mysqld stop
    rm -f /etc/init.d/mysqld
    mv $mysql $mysql.uninstall.$(date +%F_%T)
fi
if [ -f /etc/init.d/redis-server ];then
    /etc/init.d/redis-server stop
    rm -f /etc/init.d/redis-server
fi

if [ -d $INSTALLDIR ]; then
    rm -fr $INSTALLDIR/*
fi
if [ -d $LOGDIR ]; then
    rm -fr $LOGDIR/*
fi
if [ -d $SRC ]; then
    rm -fr $SRC/*
fi
if [ -d $htdocs ]; then
    rm -fr $htdocs/*
fi
if [ -d $mysql ]; then
    rm -fr $mysql/*
fi

# /etc/profile
env_line=$(cat -n /etc/profile|grep '# Cmstop Color Config'|awk '{print int($1)}')
env_line=${env_line:=80}
sed -i ''$env_line',$ d' /etc/profile