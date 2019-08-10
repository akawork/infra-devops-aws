#!/bin/bash 
# This script install Gitlab in your RHEL/Centos7 System

function install_gitlab {
    sudo yum update -y >> $LOG_INSTALL
    sudo yum install postfix htop nc -y >> $LOG_INSTALL
    sudo systemctl enable postfix >> $LOG_INSTALL
    sudo systemctl start postfix >> $LOG_INSTALL

    # Add the GitLab package repository
    curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash >> $LOG_INSTALL
    sudo yum install -y gitlab-ee >> $LOG_INSTALL
    echo "[SUCCESS] Gitlab installed complete!" >> $LOG_INSTALL
}

function config_gitlab {
    rm -rf /etc/gitlab/gitlab.rb >> $LOG_INSTALL
    cp /tmp/gitlab.rb.tpl /etc/gitlab/gitlab.rb >> $LOG_INSTALL
    gitlab-ctl reconfigure>> $LOG_INSTALL
    gitlab-ctl restart>> $LOG_INSTALL
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
        echo "This script must be run as root" >> $LOG_INSTALL
        exit 1
    fi

    if [[ $OS == "centos" || $OS == "amazon" ]];
    then
        install_gitlab
        config_gitlab
    else
        echo "[ERROR] This operating system is not supported." >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="gitlab"
LOG_INSTALL='/tmp/install_gitlab.log'
main
