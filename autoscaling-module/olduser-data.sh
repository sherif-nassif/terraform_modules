#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
apt update -y
apt install -y lighttpd
systemctl start lighttpd
systemctl enable lighttpd
touch /var/www/html/index.html

apt install stress
#stress --cpu 4 --io 4 --vm 4 --vm-bytes 2048 #--timeout 10s