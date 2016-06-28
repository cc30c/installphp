#!/bin/bash
#
#

PATH=/sbin:/usr/local/sbin:/usr/sbin:/usr/bin:/bin

# ----- Config -----
htdocs="/data/www"
mysql="/data/mysql"
backup="/backup"
TimeZone="/usr/share/zoneinfo/Asia/Shanghai"    # 时区，国外服务器请置空

# ----- Install Config -----
INSTALLDIR="/usr/local/server"
LOGDIR="/var/log/server"
YUM="/etc/yum.repos.d"
SRC="/usr/local/src"
CURDIR="$CURDIR"

# ----- DNS Config -----
grep 114.114.114.114 /etc/resolv.conf||echo 'nameserver 114.114.114.114' >> /etc/resolv.conf

# ----- DateTime Config for inland Server -----
netstat -antp|grep LISTEN|grep ntpd && /etc/init.d/ntpd stop
chkconfig ntpd off
[ -f /etc/localtime -a ! -f /etc/localtime.default ] && cp /etc/localtime /etc/localtime.default
[ -f /etc/localtime -a -f $TimeZone ] && mv /etc/localtime /etc/localtime.$(date +%F_%T)
[ -f $TimeZone ] && \cp $TimeZone /etc/localtime
/usr/sbin/ntpdate us.pool.ntp.org
hwclock --systohc

# ----- Limits Config -----
grep '#USERDEFINE Limits' /etc/security/limits.conf> /dev/null 2>&1 ||cat >> /etc/security/limits.conf <<LIMITS
# USERDEFINE Limits $(date +%F_%T)
*   soft    nproc  65535
*   hard    nproc  65535
*   soft    nofile  65535
*   hard    nofile  65535
LIMITS
ulimit -HSn 65535vi /et

# ------ Color Config ------
grep '^# USERDEFINE Color Config' /etc/profile>/dev/null 2>&1 || cat >> /etc/profile <<COLOR
# USERDEFINE Color Config $(date +%F_%T)
export red='\e[1;31m'
export redbg='\e[1;41m'
export blue='\e[1;34m'
export bluebg='\e[1;44m'
export green='\e[1;32m'
export greenbg='\e[1;42m'
export eol='\e[0m'
COLOR
source /etc/profile

# ------ Check Server Distribution ------
x86_64=`uname -i`
distribution=`cat /etc/redhat-release|awk '{print $1}'`
release=''
_ERROR=""
[ "$distribution" == "CentOS" ] && release=`cat /etc/redhat-release|awk '{print int($3)}'`
[ "$distribution" == "Red" ] && release=`cat /etc/redhat-release|awk '{print int($7)}'`
[ "$distribution" != "CentOS" ] && [ "$distribution" != "Red" ] && _ERROR="${redbg}${green}Error: System not CentOS or RedHat, please check distribution...{$eol}"
[ "$_ERROR" != "" ] && echo -e $_ERROR

# ----- Check Root User Privileges -----
if [ $(id -u) != 0 ]; then
    echo -e "${redbg}${green}Error: You Must Be root To Run This Script, su root Please ...{$eol}"
    exit 1
fi

# ------ Clear Install Log -----
[ -f $CURDIR/install.log ] && rm -f $CURDIR/install.log

# ------ Add Defination to Env -----
grep '^# USERDEFINE Config' /etc/profile >/dev/null 2>&1||cat >> /etc/profile <<CONFIG
# USERDEFINE Config $(date +%F_%T)
CURDIR="$CURDIR"
htdocs="$htdocs"
mysql="$mysql"
backup="$backup"
TimeZone="$TimeZone"
CONFIG

grep '^#USERDEFINE Install Config' /etc/profile >/dev/null 2>&1||cat >> /etc/profile <<INSTALL

#USERDEFINE Install Config $(date +%F_%T)
INSTALLDIR="$INSTALLDIR"
LOGDIR="$LOGDIR"
YUM="$YUM"
SRC="$SRC"
CURDIR="$CURDIR"
INSTALL

source /etc/profile

# alias
grep USERDEFINE ~/.bashrc >/dev/null 2>&1 || cat >> ~/.bashrc <<ALIAS
# USERDEFINE Alias $(date +%F_%T)
alias vi="/usr/bin/vim"
ALIAS
source ~/.bashrc
