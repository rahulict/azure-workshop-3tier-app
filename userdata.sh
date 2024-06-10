#!/bin/bash
apt update
apt install apache2 -y
echo Hello from VM `hostname` > /var/www/html/index.html
systemctl enable apache2
systemctl restart apache2