
#!/bin/bash

PATH=/sbin:/usr/local/sbin:/usr/sbin:/usr/bin:/bin

# ------ Config -----
CURDIR=$(pwd)
chmod -R 700 $CURDIR/shell
source $CURDIR/shell/config.sh

# ----- YUM Installing -----
source $CURDIR/shell/yum-mod.sh

# ----- MySQL Installing -----
source $CURDIR/shell/mysql-mod.sh

# ----- Nginx+LUA Installing -----
source $CURDIR/shell/tengine-mod.sh

# ----- PHP5.4.25 Installing -----
source $CURDIR/shell/php54-mod.sh

# ----- Other Software Installing (Redis And So on) -----
source $CURDIR/shell/other-mod.sh
