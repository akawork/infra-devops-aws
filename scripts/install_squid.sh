#!/bin/bash 
# This script install Squid proxy in your RHEL/Centos7 System

function install_squid {
    # Update packages
    sudo yum update -y

    # Install Squid
    sudo yum -y install squid
    sudo systemctl start squid
    sudo systemctl  enable squid

    # TODO Configuring Squid 
}

function check_service {
    if pgrep -x "$SERVICE" >/dev/null
    then
        echo "$SERVICE is running"
    else
        echo "$SERVICE stopped"
    fi
}

function main {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi

    if [[ $OS == "centos" || $OS == "amazon" ]];
    then
        install_squid
        echo "[SUCCESS] Squid installed complete!"
    else
        echo "[ERROR] This operating system is not supported."
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="squid"
main

