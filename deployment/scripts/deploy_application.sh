#!/bin/bash

. /opt/wordpress-codedeploy/deployment/scripts/setenv.sh

# Move to deploy folder
cd $CODEDEPLOY

# Copy files to apache folder
mv * /var/www/html

# Change ownership of files in apache folder
chwon -R apache:apache /var/www/html

# Change SELinux config
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/wp-content/uploads(/.*)?"
sudo restorecon -Rv /var/www/html/wp-content/uploads
