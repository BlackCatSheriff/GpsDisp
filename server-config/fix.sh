#!/bin/bash 
apps=("virtualenv" "nginx" "supervisor")
install_fail_apps=()
dirs=("/var/log/GpsDisp-hh" "/home/ubuntu/.pip" "/home/.pyenvs" "/home/backup/src/GpsDisp-hh" "/home/backup/db/GpsDisp-hh" "/home/update_web_shs")
create_fail_dirs=()
ubuntu_permissions_dirs=("/home/GpsDisp-hh/" "/var/log/GpsDisp-hh/")
chown_fail_dirs=()
config_link_files=("/etc/nginx/conf.d/nginx-GpsDisp-hh.conf" "/etc/supervisor/conf.d/supervisor-GpsDisp-hh.conf")
ln_s_fail_files=()

# ================== function ==================
# check install all apps success
function check_apps(){
    function isInstalled(){
        result=$(echo $sys_apps | grep -w "$1")
        if [[ "$result" != "" ]]
        then
            return 0
        else
            return -1
        fi
    }
    sys_apps="$(dpkg -l)"
    print_title "check apps install"
    for it in ${apps[@]};
    do
        isInstalled ${it}
        if [[ "$?" != "0" ]]
        then
            install_fail_apps+=("$it")
        fi
    done


    for it in ${install_fail_apps[@]};
    do
        print_tip "$it"" uninstalled"
        exec_cmd "sudo apt-get -y install ""$it"
    done
}

# check mkdir all success
function check_dirs(){
    print_title "check directory created"
    for dir in ${dirs[@]}
    do
        if [ ! -d "$dir" ];then
            create_fail_dirs+=("$dir")
        fi
    done 

    for it in ${create_fail_dirs[@]};
    do
        print_tip "$it"" not create"
        exec_cmd "sudo mkdir ""$it"
    done
}

function check_permissions(){
    print_title "check directory onwer"
    for dir in ${ubuntu_permissions_dirs[@]}
    do
        for f in $dir/*; 
        do  
            exec_cmd "sudo chown $USER.$USER $dir${f##*/}"
        done  
        if [ ! -O  "$dir" ]; then
            chown_fail_dirs+=("$dir")
        fi
    done 
    for it in ${chown_fail_dirs[@]};
    do
        print_tip "$it"" not change onwer"
        exec_cmd "sudo chown -R $USER.$USER $it"
    done 
}

function check_config_symbolic_link(){
    print_title "check symbolic link"
    for dir in ${config_link_files[@]}
    do
        if [ ! -L  "$dir" ]; then
            ln_s_fail_files+=("$dir")
        fi
    done
    if [[ ${#ln_s_fail_files[@]} -ne 0 ]]; then
        print_tip "have some sysbolic link not be built"
        sudo ln -s "/home/GpsDisp-hh/server-config/nginx.conf" /etc/nginx/conf.d/nginx-GpsDisp-hh.conf
        sudo ln -s "/home/GpsDisp-hh/server-config/supervisor.conf" /etc/supervisor/conf.d/supervisor-GpsDisp-hh.conf
        print_tip "built success"
    fi
}

function check_update_web_sh(){
    print_title "check update web script"
    if [ ! -x  "/home/update_web_shs/update_GpsDisp-hh.sh" ]; then
        print_tip "not found script"
        exec_cmd "sudo cp /home/GpsDisp-hh/server-config/update_web.sh /home/update_web_shs/update_GpsDisp-hh.sh"
        exec_cmd "sudo chmod +x /home/update_web_shs/update_GpsDisp-hh.sh"
    fi
}

function check_nginx_default_config(){
    print_title "check delete default nginx conf"
    if [ -f  "/etc/nginx/sites-enabled/default" ]; then
        print_tip "found default conf"
        exec_cmd "sudo rm -f /etc/nginx/sites-enabled/default"
    fi
}

function check_python_mirror(){
    print_title "check python mirror"
    if [ ! -f  "/home/ubuntu/.pip/pip.conf" ] || [[ "$(cat /home/ubuntu/.pip/pip.conf | grep "https://pypi.tuna.tsinghua.edu.cn/simple/")" == "" ]]; then
        sudo echo -e '[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple/' | sudo tee /home/ubuntu/.pip/pip.conf
        print_tip "create mirror file success"
    fi
}

# check python virtualenv include dir, python ,pip
function check_virtualenv(){
    print_title "check virtualenv directory"
    if [ ! -d  "/home/.pyenvs/GpsDisp-hh" ]; then
        print_tip "python virtual enviroment not be created, begin creating ..."
        exec_cmd "sudo virtualenv -p python3 --no-site-packages --download /home/.pyenvs/GpsDisp-hh"
    fi
    print_title "check virtual python, pip"
    if [ ! -f  "/home/.pyenvs/GpsDisp-hh/bin/python" ] || [ ! -f  "/home/.pyenvs/GpsDisp-hh/bin/pip" ]; then
        print_tip "python virtual enviroment created fail, retry..."
        exec_cmd "sudo rm -rf /home/.pyenvs/GpsDisp-hh"
        exec_cmd "sudo virtualenv -p python3 --no-site-packages --download /home/.pyenvs/GpsDisp-hh"
    fi
}

# check project python packages dependences
function check_python_dependences(){
    print_title "check project dependences"
    sudo sh -c "/home/.pyenvs/GpsDisp-hh/bin/pip freeze > /tmp/res.tmp"
    while read line1
    do
        tmp_flag=-1
        while read line2
        do
            if [ $line1 = $line2 ]
            then
                tmp_flag=0
            fi
        done < /tmp/res.tmp
        if [[ $tmp_flag -ne 0 ]]; then
            print_tip "not istalled "$line1
            exec_cmd "sudo /home/.pyenvs/GpsDisp-hh/bin/pip install $line1"
        fi
    done < /home/GpsDisp-hh/requestments.txt
}

function check_settings_config(){
    print_title "check django settings.py"
    cd /home/GpsDisp-hh/GpsDisp-hh/
    if [ `grep -c "DEBUG = False" /home/GpsDisp-hh/GpsDisp-hh/settings.py` -eq '0' ]; then
        print_tip "django settings.py DEBUG not False"
        find -name 'settings.py' | xargs perl -pi -e 's|DEBUG = True|DEBUG = False|g'
        print_tip "django settings.py DEBUG assign False success"
    fi
    if [ `grep -c "STATIC_URL = '/GpsDisp-hh/static/'" /home/GpsDisp-hh/GpsDisp-hh/settings.py` -eq '0' ]; then
        print_tip "django settings.py static url not right"
        find -name settings.py | xargs perl -pi -e "s|STATIC_URL = '/static/'|STATIC_URL = '/GpsDisp-hh/static/'|g"
        print_tip "django settings.py static url update success"
    fi
}

function retart_services(){
    print_title "restart service"
    exec_cmd "sudo service nginx reload"
    exec_cmd "sudo service supervisor restart"
}

function check_port_opened(){
    print_title "check port"
    sudo lsof -i | grep -E "7788|9090"
    sudo netstat -ap | grep -E "7788|9090"
    print_tip "if result not contain <7788> <9090>, so detail in deploy_help.md"
}

function test_web(){
    print_title "test web page"
    wget --spider -nv "$(curl -s http://ident.me/)"":7788/"
}

function exec_cmd(){
    echo "$1"
    $1 > /dev/null
}

function print_title(){
    echo -e "\033[40;36m=========== ""$(echo $1 | tr '[a-z]' '[A-Z]')"" ===========\033[0m" 
}

function print_tip(){
    echo -e "\033[40;31m"$1"\033[0m" 
}

# begin
check_apps
check_dirs
check_permissions
check_config_symbolic_link
check_update_web_sh
check_nginx_default_config
check_python_mirror
check_virtualenv
check_python_dependences
check_settings_config
retart_services
check_port_opened
test_web
# end