#!/bin/bash 
# This script install Squid proxy in your RHEL/Centos7 System

function install_squid {
    # Update packages
    sudo yum update -y >> $LOG_INSTALL

    # Install Squid
    sudo yum -y install htop nc httpd-tools squid >> $LOG_INSTALL
    sudo systemctl start squid >> $LOG_INSTALL
    sudo systemctl enable squid >> $LOG_INSTALL
}

function apply_config {
    echo "Stop Squid service" >> $LOG_INSTALL
    systemctl stop squid >> $LOG_INSTALL
    echo "Create password file and make Squid as the file owner" >> $LOG_INSTALL
    sudo touch /etc/squid/passwd && sudo chown squid /etc/squid/passwd
    echo "Copy configure to /etc/squid" >> $LOG_INSTALL
    rm -rf squid.conf mime.conf allowed_sites
    cp /tmp/squid.conf /etc/squid/squid.conf
    cp /tmp/mime.conf /etc/squid/mime.conf
    cp /tmp/allowed_sites /etc/squid/allowed_sites
    cp /tmp/blocked_sites /etc/squid/blocked_sites
    echo "Start Squid service" >> $LOG_INSTALL
    systemctl start squid >> $LOG_INSTALL
}

function create_user {
    echo "Create Squid user using for login to proxy server!" >> $LOG_INSTALL
    htpasswd -b -c /etc/squid/passwd $SQUID_USER $SQUID_PASSWORD >> $LOG_INSTALL
    systemctl restart squid >> $LOG_INSTALL
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
        echo "This script must be run as root" 1>&2  >> $LOG_INSTALL
        exit 1
    fi

    if [[ $OS == "centos" || $OS == "amazon" ]];
    then
        install_squid
        echo "[SUCCESS] Squid installed complete!"  >> $LOG_INSTALL
        apply_config
        echo "[SUCCESS] Squid update complete!"  >> $LOG_INSTALL
        create_user
        echo "[SUCCESS] Create Squid user complete!"  >> $LOG_INSTALL
    else
        echo "[ERROR] This operating system is not supported."  >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="squid"
LOG_INSTALL='/tmp/squid_install.log'
SQUID_USER=${squid_username}
SQUID_PASSWORD=${squid_password}
main

