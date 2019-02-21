# 数据库备份， /home/backup/database/<appname>


echo "==== BACK SOURCE ===="
sudo tar -zcvf  /home/backup/src/GpsDisp/"$(date +%Y-%m-%d-%H-%M-%S)".tar.gz --exclude=/home/GpsDisp/.git --exclude=/home/GpsDisp/.idea /home/GpsDisp/

echo "==== FORCE PULL SOURCE ===="
cd /home/GpsDisp
git fetch --all
git reset --hard origin/master
git pull

echo "=== RELOAD SERVICES ==="
sudo service nginx reload
sudo service supervisor restart

sudo service supervisor status
sudo service supervisor nginx

echo "=== TEST WEB ==="
wget --spider -nv "$(curl -s ident.me)"":7777/"
