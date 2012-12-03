#!/bin/bash
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin


INIT_FILE=init_file.sql
touch init_file.sql
echo "CREATE DATABASE IF NOT EXISTS $magento_db_name;" > $INIT_FILE
echo "CREATE USER '$magento_db_user'@'localhost' IDENTIFIED BY '$magento_db_password';" >> $INIT_FILE
echo "GRANT ALL PRIVILEGES ON $magento_db_name.* TO '$magento_db_user'@'localhost';" >> $INIT_FILE
echo "CREATE USER '$magento_db_user'@'%' IDENTIFIED BY '$magento_db_password';" >> $INIT_FILE
echo "GRANT ALL PRIVILEGES ON $magento_db_name.* TO '$magento_db_user'@'%';" >> $INIT_FILE
echo "FLUSH PRIVILEGES;" >> $INIT_FILE

mysql -u$init_db_username -p$init_db_password < $INIT_FILE