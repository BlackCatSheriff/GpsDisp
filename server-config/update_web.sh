#!/bin/bash 
echo "==== BACK SOURCE ===="
sudo tar -zcvf  /home/backup/src/GpsDisp/"$(date +%Y-%m-%d-%H-%M-%S)".tar.gz --exclude=/home/GpsDisp/.git --exclude=/home/GpsDisp/.idea /home/GpsDisp/

echo "==== FORCE PULL SOURCE ===="
cd /home/GpsDisp/GpsDisp
sudo git fetch --all
sudo git reset --hard origin/master
sudo git pull

sudo find -name settings.py | sudo xargs perl -pi -e 's|DEBUG = True|DEBUG = False|g'
# update seetting.py 's STATIC_URL = '/GpsDisp/static/' same with nginx.conf
sudo find -name settings.py | sudo xargs perl -pi -e "s|STATIC_URL = '/static/'|STATIC_URL = '/GpsDisp/static/'|g"

echo "=== RELOAD SERVICES ==="
sudo service nginx reload
sudo service supervisor restart

sudo service nginx status
sudo service supervisor status

echo "=== OPEN TEST PAGE ==="
wget --spider -nv "$(curl -s http://ident.me/)"":9998/index/"
