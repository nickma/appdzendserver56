#!/bin/bash

cd /tmp

# Download Magento Sample Data.
wget http://www.magentocommerce.com/downloads/assets/1.6.1.0/magento-sample-data-1.6.1.0.tar.gz

#Unapack
tar -zxvf magento-sample-data-1.6.1.0.tar.gz

#Move and install
mv magento-sample-data-1.6.1.0/magento_sample_data_for_1.6.1.0.sql data.sql
mysql -h $magento_db_address -u $dbuser -p$dbpass $dbname < data.sql