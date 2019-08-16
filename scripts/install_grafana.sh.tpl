#!/bin/bash 
# This script install Grafana in your RHEL/Centos7 System

function install_grafana {
    # Update package
    sudo yum update -y
    sudo yum -y install nc htop

    curl -LO https://dl.grafana.com/oss/release/${grafana_version}.x86_64.rpm 
    sudo yum localinstall -y ${grafana_version}.x86_64.rpm 
    
    # Copy config file (datasources, dashboard, notifiers) 
    sudo cp /tmp/datasources/* /etc/grafana/provisioning/datasources

    systemctl start grafana-server
}

function main {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" >> $LOG_INSTALL
        exit 1
    fi

    if [[ $OS == "centos" || $OS == "amazon" ]];
    then
        install_grafana
        echo "[SUCCESS] password installed complete!" >> $LOG_INSTALL
    else
        echo "[ERROR] This operating system is not supported." >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="grafana"
LOG_INSTALL='/tmp/install_grafana.log'
main
