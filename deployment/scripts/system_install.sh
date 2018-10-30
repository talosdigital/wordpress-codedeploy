#!/bin/bash

# Update and install dependencies
yum -y update
yum -y install \
    git figlet gcc-c++ nfs-utils \
    firewalld httpd mod_ssl openssl \
    psmisc bzip2 cyrus-sasl-plain \
    telnet patch net-snmp xinetd unzip jq

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

# Update PIP and AWS CLI
pip install --upgrade pip
pip install --upgrade awscli

# PHP Settings
sed -i 's/memory_limit = 128M/memory_limit = -1/g' /etc/php.ini
sed -i 's/;date.timezone =/date.timezone = America\/Bogota/g' /etc/php.ini

# Timezone
mv /etc/localtime /etc/localtime.bak
ln -s /usr/share/zoneinfo/America/Bogota /etc/localtime

# Add welcome message
if ! grep -q "Banner /etc/ssh/sshd_banner" /etc/ssh/sshd_config; then
	echo 'Banner /etc/ssh/sshd_banner' >> /etc/ssh/sshd_config
fi
echo "$(figlet $DEPLOYMENT_GROUP_NAME)" > /etc/ssh/sshd_banner
systemctl reload sshd

# Codedeploy logs
ln -sfn /opt/codedeploy-agent/deployment-root/deployment-logs/codedeploy-agent-deployments.log /home/centos/codedeploy-agent-deployments.log

# Zabbix
if [ ! -f "/etc/zabbix/zabbix_agentd.conf" ]; then
    rpm -ivh https://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm
    yum -y install zabbix-agent
    firewall-cmd --zone=public --add-port=10050/tcp --permanent
    firewall-cmd --reload
    systemctl start zabbix-agent
    systemctl enable zabbix-agent
fi

# Remove previous deploy
rm -rf /opt/wordpress-codedeploy
