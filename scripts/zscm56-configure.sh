#!/bin/bash
# Configuration for ZSCM. Set UI password, accept EULA , register with MySQL DB.
# Author: Nick Maiorsky nick@zend.com
# Import global conf 
. $global_conf

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -e

PROGNAME=`basename $0`

##Funtion to Check Error
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

## Set Zend Server Cluster Manager UI password ##
$zssetup set-password $zendmanager_ui_pass
check_error "Error during UI password setup."

## Accept ZSCM EULA ##
$zssetup accept-eula

check_error "Error during accept EULA."

## Add licenses
echo "$zendmanager_order_number" "$zendmanager_license_key"

$zssetup set-license "$zendmanager_order_number" "$zendmanager_license_key"
$zssetup set-nodes-license "$zend_order_number" "$zend_license_key"

check_error "Error entering licenses."

## Locate the my.cnf file 
my_cnf_file=
if [ -f /etc/my.cnf ]; then 
    my_cnf_file=/etc/my.cnf
elif [ -f /etc/mysql/my.cnf ]; then 
    my_cnf_file=/etc/mysql/my.cnf
fi

if [ "x$my_cnf_file" = "x" ]; then 
    echo "Neither /etc/my.cnf nor /etc/mysql/my.cnf can be found, stopping configuration"
    exit 1
fi

## Change local MySQL to accept all connections ##
sed -ie "s/\[mysqld\]/\[mysqld\]\n\
bind-address=0.0.0.0/g" $my_cnf_file

## Create Cluster Manager Database and user.

mysql -u$db_root_username -p$db_root_password -e "CREATE DATABASE IF NOT EXISTS zend_monitor;"
mysql -u$db_root_username -p$db_root_password -e "CREATE USER '$zscm_db_user'@'localhost' IDENTIFIED BY '$zscm_db_password';" 
mysql -u$db_root_username -p$db_root_password -e "GRANT CREATE,DROP,ALTER,DELETE,INDEX,INSERT,SELECT,UPDATE,CREATE TEMPORARY TABLES,LOCK TABLES,CREATE VIEW,SHOW VIEW,ALTER ROUTINE,CREATE ROUTINE,EXECUTE ON zend_monitor.* TO '$zscm_db_user'@'localhost';"
mysql -u$db_root_username -p$db_root_password -e "CREATE USER '$zscm_db_user'@'%' IDENTIFIED BY '$zscm_db_password';" 
mysql -u$db_root_username -p$db_root_password -e "GRANT CREATE,DROP,ALTER,DELETE,INDEX,INSERT,SELECT,UPDATE,CREATE TEMPORARY TABLES,LOCK TABLES,CREATE VIEW,SHOW VIEW,ALTER ROUTINE,CREATE ROUTINE,EXECUTE ON zend_monitor.* TO '$zscm_db_user'@'%';"
mysql -u$db_root_username -p$db_root_password -e "FLUSH PRIVILEGES;"

check_error "Error creating ZSCM database."

## Import MySQL schema for Cluster Monitor DB ##
mysql -u$db_root_username -p$db_root_password -D zend_monitor < $zsroot/share/mysql_create_monitor_db.sql

## Add ZSCM shared API key ##
$zssetup add-api-key -a -k $zend_api_key $zend_api_key_name

##Demo firewall settings workaround change UI port to 8080 ##

cat /usr/local/zend/gui/lighttpd/etc/lighttpd.conf | sed "s@server\.port= 10081@server\.port= 8080@" > /tmp/lhttpd.conf
mv /tmp/lhttpd.conf /usr/local/zend/gui/lighttpd/etc/lighttpd.conf


## Final restart to make sure everything is in place ## 
/etc/init.d/zend-server restart