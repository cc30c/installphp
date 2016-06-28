#!/bin/bash
#
#
#

########## Function Start ##########
function INSTALL_OTHER()
{

if [ ! -f $INSTALLDIR/php/bin/php ]; then
    echo "${redbg}${green}Error: PHP Install Failed, Check...${eol}"
    exit 1
fi

cd $CURDIR/tar
[ -f libiconv-1.14.tar.gz  ] || wget http://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz 
[ -f redis-3.2.0.tar.gz ] || wget http://mirrors.cmstop/cmstop/sources/redis-3.2.0.tar.gz

rm -rf $SRC/libiconv*
rm -rf $SRC/redis*

tar xvf $CURDIR/tar/libiconv-1.14.tar.gz -C $SRC
tar xvf $CURDIR/tar/redis-3.2.0.tar.gz -C $SRC

# ----- Redis Installing -----
cd $SRC/redis-3.2.0

[ -d "$INSTALLDIR/redis-server" ] || mkdir -p $INSTALLDIR/redis-server

make PREFIX=$INSTALLDIR/redis-server install

[ -d "$LOGDIR/redis" ] || mkdir -p $LOGDIR/redis
chmod 750 $LOGDIR/redis

[ -f "$INSTALLDIR/redis-server/redis.conf" ] && mv $INSTALLDIR/redis-server/redis.conf $INSTALLDIR/redis-server/redis.conf.$(date +%F_%T)
[ -f /etc/init.d/redis ] && mv /etc/init.d/redis /etc/init.d/redis.$(date +%F_%T)
[ -f /etc/init.d/redis-server ] && mv /etc/init.d/redis-server /etc/init.d/redis-server.$(date +%F_%T)
cp $SRC/redis-3.2.0/redis.conf $INSTALLDIR/redis-server/
sed -i 's#/usr/local/server#'$INSTALLDIR'#g' $INSTALLDIR/redis-server/redis.conf
sed -i 's#/var/log/server/redis#'$LOGDIR/redis'#g' $INSTALLDIR/redis-server/redis.conf

[ -f /etc/init.d/redis-server  -a ! -f /etc/init.d/redis-server.default ] && mv -f /etc/init.d/redis-server /etc/init.d/redis-server.default
[ -f /etc/init.d/redis-server ] && mv -f /etc/init.d/redis-server /etc/init.d/redis-server.$(date +%F_%T)
cp $CURDIR/daemon/redis-server.daemon /etc/init.d/redis-server
sed -i 's#/usr/local/server#'$INSTALLDIR'#g' /etc/init.d/redis-server
chmod 755 /etc/init.d/redis-server

[ -d $LOGDIR/redis ] || mkdir -p $LOGDIR/redis
chmod 750 $LOGDIR/redis

chkconfig redis-server on
/etc/init.d/redis-server restart

grep "$INSTALLDIR/redis-server/bin" /etc/profile || echo 'export PATH=$PATH:'$INSTALLDIR'/redis-server/bin' >> /etc/profile
source /etc/profile


# ----- nmon Installing -----
[ $(uname -i) == "x86_64" -a $(cat /etc/redhat-release|awk '{print int($3)}') == 6 ] && cp $CURDIR/tar/nmon_x86_64_centos6 /usr/bin/nmon
[ $(uname -i) == "x86_64" -a $(cat /etc/redhat-release|awk '{print int($3)}') == 5 ] && cp $CURDIR/tar/nmon_x86_64_centos5 /usr/bin/nmon
chmod +x /usr/bin/nmon

}
########## Function End ##########

INSTALL_OTHER 2>&1 | tee -a $CURDIR/install.log
