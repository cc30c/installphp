#!/bin/bash

########## Function Start ##########
# @todo: nginx limit mod
# @todo: nginx xss module: https://github.com/openresty/xss-nginx-module
# @todo: nginx iswaf module:
function INSTALL_NGINX17()
{

groupadd nginx -g 10000
useradd -u 10000 -s /sbin/nologin -M -g nginx nginx

cd $CURDIR/tar
[ -f tengine-2.1.2.tar.gz ] || wget http://mirrors.cmstop/cmstop/sources/tengine-2.1.2.tar.gz
[ -f LuaJIT-2.0.3.tar.gz ] || wget http://mirrors.cmstop/cmstop/sources/LuaJIT-2.0.3.tar.gz
[ -f ngx_devel_kit-0.2.19.tar.gz ] || wget http://mirrors.cmstop/cmstop/sources/ngx_devel_kit-0.2.19.tar.gz
[ -f lua-nginx-module-0.9.13.zip ] || wget http://mirrors.cmstop/cmstop/sources/lua-nginx-module-0.9.13.zip
[ -f redis2-nginx-module-0.11.tar.gz ] || wget http://mirrors.cmstop/cmstop/sources/redis2-nginx-module-0.11.tar.gz
[ -f echo-nginx-module-0.53.tar.gz ] || wget http://mirrors.cmstop/cmstop/sources/echo-nginx-module-0.53.tar.gz

[ -d "$SRC/tengine-2.1.2" ] && rm -rf $SRC/tengine-2.1.2 $SRC/tengine-2.1.2*
[ -d "$SRC/LuaJIT-2.0.3" ] && rm -rf $SRC/LuaJIT-2.0.3*
[ -d "$SRC/ngx_devel_kit-0.2.19" ] && rm -rf $SRC/ngx_devel_kit-0.2.19 $SRC/ngx_devel_kit-0.2.19*
[ -d "$SRC/lua-nginx-module-0.9.13" ] && rm -rf $SRC/lua-nginx-module-0.9.13 $SRC/lua-nginx-module-0.9.13*
[ -d "$SRC/redis2-nginx-module-0.11" ] && rm -rf $SRC/redis2-nginx-module-0.11*
[ -d "$SRC/echo-nginx-module-0.53" ] && rm -rf $SRC/echo-nginx-module-0.53*

tar xvzf $CURDIR/tar/LuaJIT-2.0.3.tar.gz -C $SRC
tar xvzf $CURDIR/tar/tengine-2.1.2.tar.gz -C $SRC
tar xvzf $CURDIR/tar/ngx_devel_kit-0.2.19.tar.gz -C $SRC
unzip $CURDIR/tar/lua-nginx-module-0.9.13.zip -d $SRC
tar xvf $CURDIR/tar/redis2-nginx-module-0.11.tar.gz -C $SRC
tar xvf $CURDIR/tar/echo-nginx-module-0.53.tar.gz -C $SRC

cd $SRC/LuaJIT-2.0.3
make
make install

export LUAJIT_LIB=/usr/local/lib
export LUAJIT_INC=/usr/local/include/luajit-2.0/

echo "==================== INSTALL_NGINX14 ===================="
clear
cd $SRC/tengine-2.1.2
./configure \
--user=nginx \
--group=nginx \
--prefix=$INSTALLDIR/tengine \
--conf-path=$INSTALLDIR/tengine/conf/nginx.conf \
--pid-path=$INSTALLDIR/tengine/nginx.pid \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gzip_static_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_gunzip_module \
--with-http_image_filter_module \
--without-mail_pop3_module \
--without-mail_imap_module \
--without-mail_smtp_module \
--add-module=$SRC/lua-nginx-module-0.9.13 \
--add-module=$SRC/echo-nginx-module-0.53 \
--add-module=$SRC/ngx_devel_kit-0.2.19 \
--add-module=$SRC/redis2-nginx-module-0.11

[ "$?" == 1 ] && exit

make
make install


echo "/usr/local/lib" > /etc/ld.so.conf.d/lua_lib.conf
ldconfig

[ -d $htdocs/default ] || mkdir -p $htdocs/default
chown -R root:nginx $htdocs

# ---- Create robots.txt
cat > $htdocs/default/robots.txt <<ROBOTS
User-Agent: *
Disallow: /
ROBOTS

[ -d $LOGDIR/nginx ] || mkdir -p $LOGDIR/nginx
chown -R nginx:nginx $LOGDIR/nginx
chmod 750 $LOGDIR/nginx

cd $INSTALLDIR/tengine/conf/
[ -f nginx.conf -a ! -f nginx.conf.default ] && mv nginx.conf nginx.conf.default
[ -f nginx.conf ] && mv -f nginx.conf nginx.conf.$(date +%F_%T)
cp $CURDIR/conf/nginx.conf $INSTALLDIR/tengine/conf/
cp $CURDIR/conf/injection.lua $INSTALLDIR/tengine/conf/
cp $CURDIR/conf/cc.lua $INSTALLDIR/tengine/conf/
sed -i 's#/www/htdocs#'$htdocs'#g' $INSTALLDIR/tengine/conf/nginx.conf
sed -i 's#/var/log/nginx#'$LOGDIR/nginx'#g' $INSTALLDIR/tengine/conf/nginx.conf
sed -i 's#/var/log/server/nginx#'$LOGDIR/nginx'#g' $INSTALLDIR/tengine/conf/nginx.conf
sed -i 's#/usr/local/server/nginx#'$INSTALLDIR/tengine'#g' $INSTALLDIR/tengine/conf/nginx.conf
mkdir -p $INSTALLDIR/tengine/conf/vhosts

[ -f /etc/init.d/nginx ] && mv -f /etc/init.d/nginx /etc/init.d/nginx.$(date +%F_%T)
cp $CURDIR/daemon/nginx.daemon /etc/init.d/tengine
sed -i 's#/usr/local/server#'$INSTALLDIR'#g' /etc/init.d/tengine
chmod 755 /etc/init.d/tengine

[ -f /etc/logrotate.d/nginxlog ] && mv /etc/logrotate.d/nginxlog /etc/logrotate.d/nginxlog.$(date +%F_%T)
\cp $CURDIR/conf/nginxlog /etc/logrotate.d/
sed -i 's#/var/log/nginx#'$LOGDIR/nginx'#g' /etc/logrotate.d/nginxlog
[ -f /etc/init.d/syslog ] && /etc/init.d/syslog restart
[ -f /etc/init.d/rsyslog ] && /etc/init.d/rsyslog restart


grep "$INSTALLDIR/tengine/sbin/" /etc/profile || echo 'export PATH=$PATH:'$INSTALLDIR'/tengine/sbin/' >> /etc/profile
source /etc/profile

chkconfig tengine on
/etc/init.d/tengine start

[ "$?" == 0 ] || echo -e "${redbg}${green}Error: Failed to Start nginx, please Check ...{$eol}" && exit 1

}
########## Function End ##########

INSTALL_NGINX17 2>&1 | tee -a $CURDIR/install.log
