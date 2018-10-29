#!/bin/bash

#Add Firewall Rule for External Access
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

# Change SELinux configuration
setsebool -P httpd_can_network_connect_db=1
setsebool -P httpd_can_network_connect=1
setsebool -P httpd_can_sendmail=1
