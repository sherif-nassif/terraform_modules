#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
apt update -y
apt install -y lighttpd
systemctl start lighttpd
systemctl enable lighttpd
touch /var/www/html/index.html
#echo "<html><head><title>hello</title></head><body><h1>Hello Sapper Team</h1><p style="font-size:2em">Current time: <span id="current-time" style="font-size:2em"></span></p><script>setInterval(()=>document.getElementById("current-time").innerText=new Date().toLocaleTimeString(),1e3)</script></body></html>" > /var/www/html/index.html
echo "<html><head><title>Hello Sapper Team</title></head><body><h1>Hello Sapper Team</h1></body></html>" > /var/www/html/index.html

apt install stress
#stress --cpu 4 --io 4 --vm 4 --vm-bytes 2048 #--timeout 10s