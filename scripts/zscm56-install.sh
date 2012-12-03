#!/bin/bash
# Add permisions to allow Zend nodes to connect. 
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

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
sed -ie "s/\[mysqld\]/\[mysqld\]\n\bind-address=0.0.0.0/g" $my_cnf_file
sed -ie "s/\(.*\)\(old_password\)/\#\1\2/g" $my_cnf_file

## Restart MySQL
/etc/init.d/mysqld restart

INIT_FILE=zs_perm.sql
touch $INIT_FILE
echo "GRANT ALL PRIVILEGES ON *.* TO '$zsdb_root_username'@'%' IDENTIFIED BY '$zsdb_root_password';" >> $INIT_FILE
echo "FLUSH PRIVILEGES;" >> $INIT_FILE

mysql -u"$zsdb_root_username" -p"$zsdb_root_password" < $INIT_FILE
rm -rf $INIT_FILE