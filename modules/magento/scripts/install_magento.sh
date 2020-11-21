#!/bin/bash
#set -x

cd /var/www/html

bin/magento setup:install --db-host ${mds_ip}  --db-name ${magento_schema} --db-user ${magento_name} --db-password '${magento_password}' --elasticsearch-host ${elastic_ip} --elasticsearch-port 9200

cd /var/www
chown apache. -R html

systemctl start httpd
systemctl enable httpd

echo "Magento deployed and Apache started !"
