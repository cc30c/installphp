#!/bin/bash
#
#

PATH=/sbin:/usr/local/sbin:/usr/sbin:/usr/bin:/bin

# ------ Check SELinux Status -----
selinux=$(sestatus | awk '{print $3}')
if [ "$selinux" != "disabled" ]; then
    sed -i "s#SELINUX=.*#SELINUX=disabled#g" /etc/selinux/config
    echo -e "${redbg}${green}Error: SELinux is Enforcing, \"/etc/selinux/config\" has been changed, you need to reboot and try again... ${eol}"
    exit 1
fi

# ------ Check Installation -----
IS_INSTALLED=0
netstat -antp|grep LISTEN|grep mysqld && echo -e "${redbg}${green}Error: mysqld is already running, please stop and uninstall first... ${eol}" && IS_INSTALLED=1
netstat -antp|grep LISTEN|grep nginx && echo -e "${redbg}${green}Error: nginx is already running, please stop and uninstall first... ${eol}" && IS_INSTALLED=1 
netstat -antp|grep LISTEN|grep 'php-fpm\|php-cgi' && echo -e "${redbg}${green}Error: php-fpm is already running, please and uninstall stop first... ${eol}" && IS_INSTALLED=1
netstat -antp|grep LISTEN|grep redis && echo -e "${redbg}${green}Error: redis is already running, please stop and uninstall first... ${eol}" && IS_INSTALLED=1
[ "$IS_INSTALLED" != "0" ] && exit 1

# ----- Create Directories -----
[ -d $INSTALLDIR ] || mkdir -p $INSTALLDIR
[ -d $LOGDIR ] || mkdir -p $LOGDIR
[ -d $SRC ] || mkdir -p $SRC

[ ! -f "$YUM/CentOS${release}-Base-163.repo" -a "$1" == "" ] && curl http://mirrors.163.com/.help/CentOS${release}-Base-163.repo -o $YUM/CentOS${release}-Base-163.repo
[ $distribution == "Red" ] && [ $release == "5" ] && sed -i 's#$releasever#5.10#g' $YUM/CentOS${release}-Base-163.repo
[ $distribution == "Red" ] && [ $release == "6" ] && sed -i 's#$releasever#6.6#g' $YUM/CentOS${release}-Base-163.repo

yum_param="--nogpgcheck --noplugins --skip-broken "
[ "$1" != "" ] && yum_param=$yum_param"--disablerepo=* --enablerepo=$1 "
[ "$1" != "" ] && sed -i 's#^keepcache=.*#keepcache=1#g' /etc/yum.conf
[ "$1" != "" ] && yum clean all
[ "$1" != "" ] && yum $yum_param -y update

yum $yum_param -y update bash glibc* nscd kernel-devel
yum $yum_param -y install ntp ntpdate man createrepo at vsftpd inotify-tools subversoin parted tree
yum $yum_param -y install vim lrzsz wget zip unzip mlocate dos2unix unix2dos dmidecode lshw
yum $yum_param -y install chkconfig vixie-cron crontabs screen tree e2fsprogs sed ftp sar oprofiled
yum $yum_param -y install tcpdump telnet sysstat lsof strace iptraf iotop ifstat openssh-clients

yum $yum_param -y install setuptool ntsysv system-config-firewall-tui system-config-network-tui gcc gcc-c++ 
yum $yum_param -y install autoconf automake make cmake libtool libXaw dialog expect expat-devel
yum $yum_param -y install libevent libevent-devel patch rsync httpd sendmail
yum $yum_param -y install vsftpd ipvsadm keepalived

cd $CURDIR/tar/
# release=`cat /etc/redhat-release|awk '{print int($3)}'`
if [ "$1" == "" ]; then
    if [ "$release" != 6 ]; then
        if [ `uname -m` == 'x86_64' ]; then
            [ -f rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm ] || wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm
            rpm -ivh rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm
        else
            [ -f rpmforge-release-0.5.3-1.el5.rf.i386.rpm ] || wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el5.rf.i386.rpm
            rpm -ivh rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm
        fi
    else
        if [ `uname -m` == 'x86_64' ]; then
            [ -f rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm ] || wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
            rpm -ivh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
        else
            [ -f rpmforge-release-0.5.3-1.el6.rf.i686.rpm ] && wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.i686.rpm
            rpm -ivh rpmforge-release-0.5.3-1.el6.rf.i686.rpm
        fi
    fi
fi

yum $yum_param -y install libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel
yum $yum_param -y install glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn 
yum $yum_param -y install libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers libpcap libpcap-devel
yum $yum_param -y install libmcrypt libmcrypt-devel readline-devel pcre-devel net-snmp net-snmp-devel memcached
yum $yum_param -y install libtool-ltdl-devel libaio libaio-devel bison gd-devel perl perl-devel perl-ExtUtils-Embed
yum $yum_param -y install rkhunter chkrootkit tripwire neon apr apr-util
