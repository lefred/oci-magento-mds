#!/bin/bash
#set -x

firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --reload

setsebool -P httpd_can_network_connect=1
setsebool -P httpd_can_network_connect_db 1

echo "Local Security Granted !"
