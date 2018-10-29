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

# Change SELinux configuration
setsebool -P httpd_can_network_connect_db=1
setsebool -P httpd_can_network_connect=1
setsebool -P httpd_can_sendmail=1


