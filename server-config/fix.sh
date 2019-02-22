#!/bin/bash 
apps=("virtualenv" "nginx" "supervisor")
install_fail_apps=()
dirs=("/var/log/GpsDisp" "/home/ubuntu/.pip" "/home/.pyenvs" "/home/backup/src/GpsDisp" "/home/backup/db/GpsDisp" "/home/update_web_shs")
create_fail_dirs=()
ubuntu_permissions_dirs=("/home/GpsDisp/" "/var/log/GpsDisp/")
chown_fail_dirs=()
config_link_files=("/etc/nginx/conf.d/nginx-GpsDisp.conf" "/etc/supervisor/conf.d/supervisor-GpsDisp.conf")
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
    for dir in ${dubuntu_permissions_dirsirs[@]}
    do
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
        sudo ln -s "/home/GpsDisp/server-config/nginx.conf" /etc/nginx/conf.d/nginx-GpsDisp.conf
        sudo ln -s "/home/GpsDisp/server-config/supervisor.conf" /etc/supervisor/conf.d/supervisor-GpsDisp.conf
        print_tip "built success"
    fi
}

function check_update_web_sh(){
    print_title "check update web script"
    if [ ! -x  "/home/update_web_shs/update_GpsDisp.sh" ]; then
        print_tip "not found script"
        exec_cmd "sudo cp /home/GpsDisp/server-config/update_web.sh /home/update_web_shs/update_GpsDisp.sh"
        exec_cmd "sudo chmod +x /home/update_web_shs/update_GpsDisp.sh"
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
    if [ ! -d  "/home/.pyenvs/GpsDisp" ]; then
        print_tip "python virtual enviroment not be created, begin creating ..."
        exec_cmd "sudo virtualenv -p python3 --no-site-packages --download /home/.pyenvs/GpsDisp"
    fi
    print_title "check virtual python, pip"
    if [ ! -f  "/home/.pyenvs/GpsDisp/bin/python" ] || [ ! -f  "/home/.pyenvs/GpsDisp/bin/pip" ]; then
        echo "==================== !!!!!!!!!!!!!!!!! ========================"
        print_tip "python virtual enviroment created fail, retry..."
        exec_cmd "sudo rm -rf /home/.pyenvs/GpsDisp"
        exec_cmd "sudo virtualenv -p python3 --no-site-packages --download /home/.pyenvs/GpsDisp"
    fi
}

# check project python packages dependences
function check_python_dependences(){
    print_title "check project dependences"
    sudo sh -c "/home/.pyenvs/GpsDisp/bin/pip freeze > /tmp/res.tmp"
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
            exec_cmd "sudo /home/.pyenvs/GpsDisp/bin/pip install $line1"
        fi
    done < /home/GpsDisp/requestments.txt
}

function check_settings_config(){
    print_title "check django settings.py DEBUG"
    cd /home/GpsDisp/GpsDisp/
    if [ `grep -c "DEBUG = False" /home/GpsDisp/GpsDisp/settings.py` -eq '0' ]; then
        print_tip "django settings.py DEBUG not False"
        find -name 'settings.py' | xargs perl -pi -e 's|DEBUG = True|DEBUG = False|g'
        print_tip "django settings.py DEBUG assign False"
    fi
    if [ `grep -c "STATIC_URL = '/GpsDisp/static/'" /home/GpsDisp/GpsDisp/settings.py` -eq '0' ]; then
        print_tip "django settings.py static url not right"
        find -name settings.py | xargs perl -pi -e "s|STATIC_URL = '/static/'|STATIC_URL = '/GpsDisp/static/'|g"
        print_tip "django settings.py static url update success"
    fi
}

function check_port_opened(){
    print_title "check port"
    sudo lsof -i | grep -E "7777|8999"
    sudo netstat -ap | grep -E "7777|8999"
    print_tip "detail in  deploy_help.md"
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
check_port_opened
# end