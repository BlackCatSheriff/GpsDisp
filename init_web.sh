#!/bin/sh 
WEB_NAME="GpsDisp"
PYTHON_IMG_URL="https://pypi.tuna.tsinghua.edu.cn/simple/"
WEB_BASE_DIR=/home/$WEB_NAME/

# update computer time zone
sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# init web environment 
sudo apt-get update
sudo apt-get -y install python-pip python-virtualenv python-dev nginx supervisor

# create log, pip download configuration, python virtual env directory
sudo mkdir /var/log/$WEB_NAME ~/.pip /home/.pyenvs/

# update permission
sudo chown -R $USER.$USER $WEB_BASE_DIR
sudo chown -R $USER.$USER /var/log/$WEB_NAME/

# remove default nginx configuration
sudo rm -f /etc/nginx/sites-enabled/default

# add link this app nginx configuration
sudo ln -s $WEB_BASE_DIR"nginx-hlc.conf" /etc/nginx/conf.d/nginx-hlc.conf
sudo ln -s $WEB_BASE_DIR"supervisor-hlc.conf" /etc/supervisor/conf.d/supervisor-hlc.conf

# update python image url
sudo echo -e "[global]\nindex-url = "$PYTHON_IMG_URL > ~/.pip/pip.conf

# build python virtual env
sudo virtualenv -p python3 --no-site-packages --download /home/.pyenvs/$WEB_NAME

# install 3-rd libs
sudo /home/.pyenvs/$WEB_NAME/bin/pip install -r $WEB_BASE_DIR"requestments.txt"

# check setting debug
cd $WEB_BASE_DIR$WEB_NAME
find -name settings.py | xargs perl -pi -e 's|DEBUG = True|DEBUG = False|g'

# open nginx, supervisor
sudo service supervisor start
sudo service nginx start

# open firewall port
sudo iptables -I INPUT -p tcp --dport 7777 -j ACCEPT
sudo iptables-save

lsof -i :8999

wget "$(curl ident.me)"":7777/"
