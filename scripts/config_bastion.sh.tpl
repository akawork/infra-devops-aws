#!/bin/bash

function config_proxy {
    touch /etc/profile.d/proxy.sh
    echo 'export {http,https}_proxy="http://${squid_username}:${squid_password}@${squid_ip}:${squid_port}"' | sudo tee -a /etc/profile.d/proxy.sh
    echo 'export no_proxy="127.0.0.1,localhost"' | sudo tee -a /etc/profile.d/proxy.sh
    sh /etc/profile.d/proxy.sh
    env | grep proxy >> $LOG_INSTALL
}

function install_tools {
    yum update -y && yum install -y nc htop >> $LOG_INSTALL
}

function config_ssh_key {
    echo "Set permission for ${internal_ssh_key}" >> $LOG_INSTALL
    chmod -R 400 /home/ec2-user/${internal_ssh_key}
}

function check_internet_connect {
    # source /etc/profile
    case "$(curl -s --max-time 200 -I https://google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
        [23]) echo "HTTP connectivity is up";;
        5) echo "The web proxy won't let us through";;
        *) echo "The network is down or very slow";;
    esac
}

function main {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 1>&2  >> $LOG_INSTALL
        exit 1
    fi

    if [[ $OS == "centos" || $OS == "amazon" ]];
    then
        config_proxy
        echo "[SUCCESS] Configuration Proxy complete!"  >> $LOG_INSTALL
        check_internet_connect
        config_ssh_key
        echo "[SUCCESS] Configuration SSH key complete!"  >> $LOG_INSTALL
        install_tools
        echo "[SUCCESS] Install tools complete!"  >> $LOG_INSTALL
    else
        echo "[ERROR] This operating system is not supported."  >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
LOG_INSTALL='/tmp/bastion_config.log'
main
