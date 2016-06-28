# installphp
install php on linux

防火墙
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT 
/etc/rc.d/init.d/iptables save
/etc/init.d/iptables restart
查看
/etc/sysconfig/iptables
ifup eth0

更新git 安装git以后再执行下面操作
yum -y remove git
wget -O git.zip https://github.com/git/git/archive/master.zip
unzip git.zip
cd git-master
autoconf
./configure --prefix=/usr/local
make && make install
rm /usr/bin/git
ln -s /usr/local/git/bin/git /usr/bin/git

yaf本地安装2.3.5,而不是3.0.2

/usr/local/server/php/etc/php.ini 启用proc_open() phpinfo() 并且启用yaf
/usr/local/server/php/etc/php-fpm.ini 删除cmstop 并且修改缓存目录路径到你的站点

为了防止redis启动卡死centos,修改redis.conf
daemonize yes

安装wine
rpm -ivh http://mirrors.yun-idc.com/epel/6/i386/epel-release-6-8.noarch.rpm