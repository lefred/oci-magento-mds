#!/bin/bash
#set -x

cd /var/www/html

bin/magento setup:install --ansi --db-host ${mds_ip}  --db-name ${magento_schema} --db-user ${magento_name} --db-password '${magento_password}' --elasticsearch-host ${opendistro_ip} --elasticsearch-port 9200 --admin-firstname='${magento_admin_firstname}' --admin-lastname='${magento_admin_lastname}' --admin-user=admin='${magento_admin_login}' --admin-password='${magento_admin_password}' --admin-email='${magento_admin_email}'

cd /var/www
chown apache. -R html

systemctl start httpd
systemctl enable httpd

echo "Magento deployed and Apache started !"
