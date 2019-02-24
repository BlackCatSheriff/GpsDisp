#!/bin/bash 
sudo apt-get install -y gcc make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev

sudo mkdir /etc/python3.7.2

sudo wget -P /home/$USER https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tgz 

sudo tar zxvf  /home/$USER/Python-3.7.2.tgz -C  /home/$USER
sudo rm /home/$USER/Python-3.7.2.tgz

cd /home/$USER/Python-3.7.2
sudo ./configure --enable-optimizations --prefix=/etc/python3.7.2

sudo make 
sudo make install

sudo virtualenv --python=/etc/python3.7.2/bin/python3 --no-site-packages --download /home/.pyenvs/GpsDisp