#!/bin/bash

# This script install sonarqube in your RHEL/Centos7 System.

function install_sonar {
    #update package
    sudo yum update -y
    #yum install java
    sudo yum -y install wget unzip htop nc
    sudo amazon-linux-extras install java-openjdk11 -y
    cp /etc/profile /etc/profile_backup
    echo 'export JAVA_HOME=/usr/lib/jvm/jre-11-openjdk' | sudo tee -a /etc/profile
    echo 'export JRE_HOME=/usr/lib/jvm/jre' | sudo tee -a /etc/profile
    source /etc/profile
    # pull repo sonarqube
    wget https://binaries.sonarsource.com/Distribution/sonarqube/${sonar_version}.zip
    # install SonarQube at /opt/sonarqube
    unzip ${sonar_version}.zip -d /opt
    mv /opt/${sonar_version} /opt/sonarqube
    # Create sonar user and sonar group
    sudo groupadd sonar
    sudo useradd -c "Sonar System User" -d /opt/sonarqube/ -g sonar -s /bin/bash sonar
    sudo chown -R sonar:sonar /opt/sonarqube/
    
    # Make a backup configuration file.
    cp /opt/sonarqube/conf/sonar.properties /opt/sonarqube/conf/sonar.properties.bka

    # Change user to run Sonar
    sed -i 's/#RUN_AS_USER=/RUN_AS_USER=sonar/g' /opt/sonarqube/bin/linux-x86-64/sonar.sh

    # Make a file to manage Sonar service via systemctl
cat > /etc/systemd/system/sonar.service << EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always
LimitNOFILE = 65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

    #Allow the required HTTP port through the system firewall.
    # sudo firewall-cmd --add-service=http --permanent
    # sudo firewall-cmd --reload
    
    # Set vm.max_map_count
    echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
    sysctl -p
    # Start sonarqube
    sudo systemctl start sonar
    sudo systemctl enable sonar
}

function config_sonar {
    sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=${db_username}/g' /opt/sonarqube/conf/sonar.properties
    sed -i 's/#sonar.jdbc.password=/sonar.jdbc.password=${db_password}/g' /opt/sonarqube/conf/sonar.properties
    sed -i '/#----- PostgreSQL*/a sonar.jdbc.url=jdbc:postgresql://${db_endpoint}/${db_name}' /opt/sonarqube/conf/sonar.properties

    systemctl restart sonar
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
        install_sonar
        config_sonar
        echo "[SUCCESS] Sonar installed complete!" >> $LOG_INSTALL
    else
        echo "[ERROR] This operating system is not supported." >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="sonar"
LOG_INSTALL='/tmp/install_sonar.log'
main

