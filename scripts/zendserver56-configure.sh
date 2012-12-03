#!/bin/bash
# Author: Nick Maiorsky nick@zend.com
# Import global conf 
. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -e

PROGNAME=`basename $0`
ADD_SERVER_OPTIONS="--retry 150 --wait 5 "

## Function to display errors and exit ##
function check_error()
{
   if [ ! "$?" = "0" ]; then
      error_exit "$1"; 
   fi
}

## Function To Display Error and Exit
function error_exit()
{
   echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
   exit 1
}

## Configure Zend Server tool ##
zsroot=/usr/local/zend
zssetup=$zsroot/bin/zs-setup
zsmanage=$zsroot/bin/zs-manage

## Set Zend Server UI password ##
$zssetup set-password $zendnode_ui_pass

check_error "Error during UI password setup."

## Join Zend Cluster configured as cluster node ##

if [ "$zendnode_is_node" = "1" ] ; then 
        $zsmanage cluster-add-server \
        $ADD_SERVER_OPTIONS \
        -N "$zend_api_key_name" \
        -K "$zend_api_key" \
        -U "https://$zend_zscm_host:10082/ZendServerManager" \
        -n "$zend_self_name" \
        -p "$zendnode_ui_pass" \
        -u "https://$zend_self_addr:10082/ZendServer"
else
         $zssetup set-license "$zend_order_number" "$zend_license_key"
fi

## Enable logrotate for Zend Server logs ##

touch /etc/logrotate.d/zend-server
chmod 655 /etc/logrotate.d/zend-server

cat > /etc/logrotate.d/zend-server <<EOF
/usr/local/zend/var/log/*.log {
        size 5M
        missingok
        rotate 10
        compress
        delaycompress
        copytruncate
}
EOF

## Install and enable cron service ##

yum -y install vixie-cron
service crond start
chkconfig crond on

## Check if logrotate is in daily cron jobs.

if [ -f /etc/cron.daily/logrotate ]
   then 
       echo "Logrotate daily configuration exists." 
   else   
        check_error "Logrotate cron daily is missing."
fi    