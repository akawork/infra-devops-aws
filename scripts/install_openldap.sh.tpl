#!/bin/bash
# Usage
# First create an encrypted password to be used as connection pass
# and pass as a parameter with the script. To create use: slappasswd

function install_openldap() {
    # Clean packages
    yum clean all && yum update -y
    # Install openldap as service manager
    yum install -y openldap openldap-clients openldap-servers
    # Start service and enable service start from boot
    systemctl start slapd
    systemctl enable slapd
}

function config_openldap {
    # Generate root password
    root_password=slappasswd -s ${openldap_password}
    echo "olcRootPW: $root_password" >> /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{2\}bdb.ldif
}

function main() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" >>$LOG_INSTALL
        exit 1
    fi

    if [[ $OS == "centos" || $OS == "amazon" ]]; then
        install_openldap
        config_openldap
        echo "[SUCCESS] OpenLdap installed complete!" >>$LOG_INSTALL
    else
        echo "[ERROR] This operating system is not supported." >>$LOG_INSTALL
    fi
}

OS=$(cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq)
SERVICE="openldap"
LOG_INSTALL='/tmp/install_openldap.log'

main
