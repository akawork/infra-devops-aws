#!/bin/bash 
# This script install Jenkins in your RHEL/Centos7 System

function install_jenkins {
    #update package
    sudo yum update -y

    #yum install java
    sudo yum -y install wget # java-1.8.0-openjdk.x86_64 
    sudo amazon-linux-extras install java-openjdk11 -y
    cp /etc/profile /etc/profile_backup
    echo 'export JAVA_HOME=/usr/lib/jvm/jre-11-openjdk' | sudo tee -a /etc/profile
    echo 'export JRE_HOME=/usr/lib/jvm/jre' | sudo tee -a /etc/profile
    source /etc/profile

    # pull Repository information 
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    #import repo to package "rpm" 
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    #install jenkins 
    sudo yum -y install ${jenkins_version}
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    #get password for jenkins 
    # echo "password to unlock jenkins "
    # cat /var/lib/jenkins/secrets/initialAdminPassword
    echo "[SUCCESS] Jenkins installed complete!" >> $LOG_INSTALL
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
        install_jenkins
    else
        echo "[ERROR] This operating system is not supported." >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="jenkins"
LOG_INSTALL='/tmp/install_jenkins.log'
main

