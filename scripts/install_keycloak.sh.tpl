#!/bin/bash 
# This script install Jenkins in your RHEL/Centos7 System

function install_keycloak {
    #update package
    sudo yum update -y

    #yum install java
    sudo yum -y install java-1.8.0-openjdk.x86_64 wget

    # pull Repository information 
    cd /opt
    wget https://downloads.jboss.org/keycloak/9.0.2/keycloak-9.0.2.tar.gz
    #extract
    tar -xzvf keycloak-9.0.2.tar.gz
    mv keycloak-9.0.2 keycloak
    #change to keycloak directory ( keycloak_home)
    cd /opt/keycloak
    #config keycloak as service
    export keycloak_home=`pwd`
    sudo mkdir -p /etc/keycloak
    sudo cp -rf $keycloak_home/docs/contrib/scripts/systemd/wildfly.conf /etc/keycloak/keycloak.conf
    #create lauch.sh script
    cat > $keycloak_home/bin/launch.sh << EOF
#!/bin/bash

    $keycloak_home/bin/standalone.sh -b 0.0.0.0

EOF
    sudo chown ec2-user.ec2-user $keycloak_home/bin/launch.sh
    sudo chmod +x $keycloak_home/bin/launch.sh
    #create keycloak.service
    cat > /etc/systemd/system/keycloak.service << EOF
[Unit]
Description=The Keycloak Server
After=syslog.target network.target
Before=httpd.service
[Service]
Environment=LAUNCH_JBOSS_IN_BACKGROUND=1
EnvironmentFile=/etc/keycloak/keycloak.conf
User=ec2-user
Group=ec2-user
LimitNOFILE=102642
PIDFile=/var/run/keycloak/keycloak.pid
ExecStart=$keycloak_home/bin/launch.sh 
StandardOutput=null
[Install]
WantedBy=multi-user.target

EOF

    # create pid directory
    sudo mkdir -p /var/run/keycloak
    #Install jdbc driver
    #change to keycloak directory ( keycloak_home)
    cd /opt/keycloak
    #config keycloak as service
    export keycloak_home=`pwd`
    #download jdbc driver
    mkdir -p $keycloak_home/modules/system/layers/keycloak/org/postgresql/main
    cd $keycloak_home/modules/system/layers/keycloak/org/postgresql/main
    wget https://jdbc.postgresql.org/download/postgresql-42.2.11.jar
    #cai dat module
    cp -rf /tmp/keycloak/module.xml .

    # cau hinh standalone.xml
    cd /tmp
    chmod 755 /tmp/change_parameter.sh
    sh /tmp/change_parameter.sh
    
    #copy config
    sudo cp -rf /tmp/keycloak/standalone.xml $keycloak_home/standalone/configuration/
    
    # Active service
    sudo systemctl daemon-reload
    sudo systemctl enable keycloak
    sudo systemctl start keycloak
    sudo systemctl status keycloak
    # add administrator user with realm master
    $keycloak_home/bin/add-user-keycloak.sh -u admin -p 654321 -r master
    echo "[SUCCESS] keycloak installed complete!" >> $LOG_INSTALL
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
        install_keycloak
    else
        echo "[ERROR] This operating system is not supported." >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="keycloak"
LOG_INSTALL='/tmp/install_keycloak.log'
main

