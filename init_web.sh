#!/bin/sh 

WEB_NAME="GpsDisp"
PYTHON_IMG_URL="https://pypi.tuna.tsinghua.edu.cn/simple/"
WEB_BASE_DIR = /home/$WEB_NAME/
LOGIN_USER= "$(whoami)"

# update permission
sudo chown -R $LOGIN_USER.$LOGIN_USER $WEB_BASE_DIR
sudo chown -R $LOGIN_USER.$LOGIN_USER /var/log/$WEB_NAME/

# update computer time zone
sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

sudo apt-get update
# init web environment 
sudo apt-get -y install python-pip python-dev nginx
sudo apt-get -y install supervisor

# remove default nginx configuration
sudo rm -f /etc/nginx/sites-enabled/default

# add link this app nginx configuration
sudo ln -s $WEB_BASE_DIR"nginx-hlc.conf" /etc/nginx/conf.d/nginx-hlc.conf
sudo ln -s $WEB_BASE_DIR"supervisor-hlc.conf" /etc/supervisor/conf.d/supervisor-hlc.conf

# update python image url
mkdir ~/.pip
sudo echo -e "[global]\nindex-url = "$PYTHON_IMG_URL > ~/.pip/pip.conf

# build python virtual env
sudo pip install virtualenv
sudo mkdir /home/.pyenvs/
sudo virtualenv -p python3 --no-site-packages /home/.pyenvs/$WEB_NAME

# create log directory
sudo mkdir /var/log/$WEB_NAME

# install 3-rd libs
sudo /home/.pyenvs/$WEB_NAME/bin/pip install -r requestments.txt

# check setting debug
find -name $WEB_BASE_DIR/$WEB_NAME/settings.py | xargs perl -pi -e 's|DEBUG = True|DEBUG = False|g'

# open nginx, supervisor
sudo service supervisor start
sudo service nginx start

# open firewall port
sudo iptables -I INPUT -p tcp --dport 7777 -j ACCEPT
sudo iptables-save

lsof -i :8999

wget "$(curl ident.me)"":7777/"
