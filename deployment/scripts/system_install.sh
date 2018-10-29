#!/bin/bash

# Update and install dependencies
yum -y update
yum -y install git httpd firewalld figlet jq
# Install PHP 7 and Modules
yum install -y http://dl.iuscommunity.org/pub/ius/stable/CentOS/7/x86_64/ius-release-1.0-14.ius.centos7.noarch.rpm
yum -y update
yum -y install php72u php72u-pdo php72u-mysqlnd \
    php72u-opcache php72u-xml php72u-mcrypt \
    php72u-gd php72u-devel php72u-mysql \
    php72u-intl php72u-mbstring php72u-bcmath \
    php72u-json php72u-iconv php72u-soap

# Enable apache and firewall
systemctl enable httpd
systemctl enable firewalld

# Start apache and firewall
systemctl stop firewalld
systemctl stop httpd.service

systemctl restart dbus
usermod -d /var/www apache
systemctl start firewalld
systemctl start httpd

# Timezone
mv /etc/localtime /etc/localtime.bak
ln -s /usr/share/zoneinfo/America/Bogota /etc/localtime

# Codedeploy logs
ln -sfn /opt/codedeploy-agent/deployment-root/deployment-logs/codedeploy-agent-deployments.log /home/centos/codedeploy-agent-deployments.log

# Remove previous deploy
rm -rf /opt/wordpress-codedeploy
