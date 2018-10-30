#!/bin/bash

. /opt/wordpress-codedeploy/deployment/scripts/setenv.sh

#Add Firewall Rule for External Access
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

# Apache Config
mkdir -p /etc/httpd/sites-available
mkdir -p /etc/httpd/sites-enabled
/bin/cp $CODEDEPLOY/deployment/configs/talos.conf /etc/httpd/conf.d/talos.conf
envsubst < $CODEDEPLOY/deployment/configs/default.conf > /etc/httpd/sites-available/default.conf
envsubst < $CODEDEPLOY/deployment/configs/template.conf > /etc/httpd/sites-available/$PROJECT.conf
ln -sfn /etc/httpd/sites-available/default.conf /etc/httpd/sites-enabled/default.conf
ln -sfn /etc/httpd/sites-available/$PROJECT.conf /etc/httpd/sites-enabled/$PROJECT.conf
systemctl reload httpd

# Change SELinux configuration
setsebool -P httpd_can_network_connect_db=1
setsebool -P httpd_can_network_connect=1
setsebool -P httpd_can_sendmail=1

# Zabbix
envsubst < $CODEDEPLOY/deployment/configs/zabbix_agentd.conf > /etc/zabbix/zabbix_agentd.conf
systemctl restart zabbix-agent

# PHP
/bin/cp $CODEDEPLOY/deployment/configs/90-talos.ini /etc/php.d/90-talos.ini
