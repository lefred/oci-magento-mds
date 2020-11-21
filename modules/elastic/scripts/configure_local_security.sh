#!/bin/bash
#set -x

firewall-cmd --zone=public --permanent --add-port=9200/tcp
firewall-cmd --reload

echo "Local Security Granted !"
