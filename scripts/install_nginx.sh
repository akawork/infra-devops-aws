#!/bin/bash 
# This script install Nginx in your RHEL/Centos7 System

function install_nginx {
    # Install EPEL package repository
    if [[ $OS == "amazon" ]]; then
        sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm    	
    elif [[ $OS == "centos" ]]; then
        sudo yum install -y epel-release
    fi

    sudo yum update -y
    
    sudo yum install -y nginx certbot-nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx

    #sudo firewall-cmd --permanent --zone=public --add-service=http 
    #sudo firewall-cmd --permanent --zone=public --add-service=https
    #sudo firewall-cmd --reload
    echo "[SUCCESS] Nginx installed complete!" >> $LOG_INSTALL
}

function config_nginx {
    sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf
    sudo cp /tmp/*.conf /etc/nginx/conf.d
    sudo systemctl reload nginx
}

function check_service {
    if pgrep -x "$SERVICE" >/dev/null
    then
        echo "$SERVICE is running" >> $LOG_INSTALL
    else
        echo "$SERVICE stopped" >> $LOG_INSTALL
    fi
}

function main {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" >> $LOG_INSTALL
        exit 1
    fi

    if [[ $OS == "centos" || $OS == "amazon" ]];
    then
        install_nginx
        check_service
        config_nginx
    else
        echo "[ERROR] This operating system is not supported." >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="nginx"
LOG_INSTALL='/tmp/install_nginx.log'
main

