#!/bin/bash
# This is Magento Web Store installation script.
# Author: Nick Maiorsky nick@zend.com  
# Import global conf 
. $global_conf

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/vmware/bin:/opt/vmware/bin:/usr/local/zend/bin
export HOME=/root

clear

stty erase '^?'
    
#echo -n "Database Name: "
#read dbname
#echo -n "Database User: "
#read dbuser
#echo -n "Database Password: "
#read dbpass
#echo -n "Admin Password: "
#read adminpass
#echo -n "Store URL (with trailing slash): "
#read url
#echo -n "Include Sample Data? (y/n) "
#read sample

## Add MySQL client.

yum -y install mysql

# Change to installation location. 

cd /var/www/html

## Add properties to old stile variables.

dbname=$magento_db_name
dbuser=$magento_db_user
dbpass=$magento_db_pass
adminpass=$magento_admin_pass
url=http://$magento_url/
sample=$magento_sample

if [ "$sample" = "y" ]; then
    echo
    echo "Now installing Magento with sample data..."
    
    echo
    echo "Downloading packages..."
    echo
    
    wget http://www.magentocommerce.com/downloads/assets/1.7.0.0/magento-1.7.0.0.tar.gz
    wget http://www.magentocommerce.com/downloads/assets/1.6.1.0/magento-sample-data-1.6.1.0.tar.gz
    
    echo
    echo "Extracting data..."
    echo
    
    tar -zxvf magento-1.7.0.0.tar.gz
    tar -zxvf magento-sample-data-1.6.1.0.tar.gz
    
    echo
    echo "Moving files..."
    echo
    
    mv magento-sample-data-1.6.1.0/media/* magento/media/
    mv magento-sample-data-1.6.1.0/magento_sample_data_for_1.6.1.0.sql magento/data.sql
    mv magento/* magento/.htaccess .
    
    echo
    echo "Setting permissions..."
    echo
    
    chmod 550 mage
    chown -R apache:apache /var/www/html/
    
    echo
    echo "Importing sample products..."
    echo
        
    echo
    echo "Initializing PEAR registry..."
    echo
    
    ./mage mage-setup .
    
    echo
    echo "Cleaning up files..."
    echo
    
    rm -rf magento/ magento-sample-data-1.6.1.0/
    rm -rf magento-1.7.0.0.tar.gz magento-sample-data-1.6.1.0.tar.gz
    rm -rf index.php.sample .htaccess.sample php.ini.sample data.sql *.txt
    
    echo
    echo "Installing Magento..."
    echo
    
    php-cli -f install.php -- \
    --license_agreement_accepted "yes" \
    --locale "en_US" \
    --timezone "America/Los_Angeles" \
    --default_currency "USD" \
    --db_host "$magento_db_address" \
    --db_name "$dbname" \
    --db_user "$dbuser" \
    --db_pass "$dbpass" \
    --url "$url" \
    --use_rewrites "yes" \
    --use_secure "no" \
    --secure_base_url "" \
    --use_secure_admin "no" \
    --admin_firstname "Store" \
    --admin_lastname "Owner" \
    --admin_email "email@address.com" \
    --admin_username "admin" \
    --admin_password "$adminpass"
    
    echo
    echo "Finished installing the latest stable version of Magento With Sample Data"
    echo
    
    echo "+=================================================+"
    echo "| MAGENTO LINKS"
    echo "+=================================================+"
    echo "|"
    echo "| Store: $url"
    echo "| Admin: ${url}admin/"
    echo "|"
    echo "+=================================================+"
    echo "| ADMIN ACCOUNT"
    echo "+=================================================+"
    echo "|"
    echo "| Username: admin"
    echo "| Password: $adminpass"
    echo "|"
    echo "+=================================================+"
    echo "| ENCRYPTION KEY"
    echo "+=================================================+"
    echo "|"
    echo "| PASTE-ENCRYPTION-KEY-HERE"
    echo "|"
    echo "+=================================================+"
    echo "| DATABASE INFO"
    echo "+=================================================+"
    echo "|"
    echo "| Database: $dbname"
    echo "| Username: $dbuser"
    echo "| Password: $dbpass"
    echo "|"
    echo "+=================================================+"
    
    exit
else
    echo "Now installing Magento without sample data..."
    
    echo
    echo "Downloading packages..."
    echo
    
    wget http://www.magentocommerce.com/downloads/assets/1.7.0.0/magento-1.7.0.0.tar.gz
    
    echo
    echo "Extracting data..."
    echo
    
    tar -zxvf magento-1.7.0.0.tar.gz
    
    echo
    echo "Moving files..."
    echo
    
    mv magento/* magento/.htaccess .
    
    echo
    echo "Setting permissions..."
    echo
    
    chmod 550 mage
    chown -R apache:apache /var/www/html/

    echo
    echo "Initializing PEAR registry..."
    echo
    
    ./mage mage-setup .
    
    echo
    echo "Cleaning up files..."
    echo
    
    rm -rf magento/ magento-1.7.0.0.tar.gz
    rm -rf index.php.sample .htaccess.sample php.ini.sample *.txt
    
    echo
    echo "Installing Magento..."
    echo
    
    /usr/local/zend/bin/php-cli -f install.php -- \
    --license_agreement_accepted "yes" \
    --locale "en_US" \
    --timezone "America/Los_Angeles" \
    --default_currency "USD" \
    --db_host "$magento_db_address" \
    --db_name "$dbname" \
    --db_user "$dbuser" \
    --db_pass "$dbpass" \
    --url "$url" \
    --use_rewrites "yes" \
    --use_secure "no" \
    --secure_base_url "" \
    --use_secure_admin "no" \
    --admin_firstname "Store" \
    --admin_lastname "Owner" \
    --admin_email "email@address.com" \
    --admin_username "admin" \
    --admin_password "$adminpass"
    
    echo
    echo "Finished installing the latest stable version of Magento Without Sample Data"
    echo
    
    echo "+=================================================+"
    echo "| MAGENTO LINKS"
    echo "+=================================================+"
    echo "|"
    echo "| Store: $url"
    echo "| Admin: ${url}admin/"
    echo "|"
    echo "+=================================================+"
    echo "| ADMIN ACCOUNT"
    echo "+=================================================+"
    echo "|"
    echo "| Username: admin"
    echo "| Password: $adminpass"
    echo "|"
    echo "+=================================================+"
    echo "| ENCRYPTION KEY"
    echo "+=================================================+"
    echo "|"
    echo "| PASTE-ENCRYPTION-KEY-HERE"
    echo "|"
    echo "+=================================================+"
    echo "| DATABASE INFO"
    echo "+=================================================+"
    echo "|"
    echo "| Database: $dbname"
    echo "| Username: $dbuser"
    echo "| Password: $dbpass"
    echo "|"
    echo "+=================================================+"
    
    exit
fi