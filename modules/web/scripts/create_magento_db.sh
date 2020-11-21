#!/bin/bash 


mysqlsh ${admin_username}:'${admin_password}'@${mds_ip} --sql -e "CREATE DATABASE ${magento_schema};"
mysqlsh ${admin_username}:'${admin_password}'@${mds_ip} --sql -e "CREATE USER ${magento_name} identified by '${magento_password}';"
mysqlsh ${admin_username}:'${admin_password}'@${mds_ip} --sql -e "GRANT ALL PRIVILEGES ON ${magento_schema}.* TO ${magento_name};"

echo "Magento Database and User created !"
