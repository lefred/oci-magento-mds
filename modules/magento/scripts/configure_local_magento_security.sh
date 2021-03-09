#!/bin/bash
#set -x


chcon -R --type httpd_sys_rw_content_t /var/www/html/app/etc
chcon -R --type httpd_sys_rw_content_t /var/www/html/var
chcon -R --type httpd_sys_rw_content_t /var/www/html/pub/media
chcon -R --type httpd_sys_rw_content_t /var/www/html/pub/static
chcon -R --type httpd_sys_rw_content_t /var/www/html/generated

echo "Local Security Granted !"
