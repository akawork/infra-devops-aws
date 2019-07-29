#!/bin/bash 
# This script install Nexus repository sonatype in your RHEL/Centos7 System

function install_nexus {
    # Update packages
    sudo yum update -y

    # Install openjdk-1.8
    sudo yum -y install java-1.8.0-openjdk.x86_64

    cp /etc/profile /etc/profile_backup
    echo 'export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk' | sudo tee -a /etc/profile
    echo 'export JRE_HOME=/usr/lib/jvm/jre' | sudo tee -a /etc/profile
    source /etc/profile

    mkdir /opt/nexus

    # Download nexus and extrac
    curl -LO http://download.sonatype.com/nexus/3/${nexus_version}-unix.tar.gz

    tar -xvf ${nexus_version}-unix.tar.gz -C /opt/nexus
    rm -f ${nexus_version}-unix.tar.gz

    useradd nexus
    chown -R nexus:nexus /opt/nexus/

    #firewall-cmd --zone=public --permanent --add-port=8081/tcp
    #firewall-cmd --reload
    
    # Create systemd service
    cat > /etc/systemd/system/nexus.service << EOF
[Unit]
Description=nexus service
After=network.target
  
[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/${nexus_version}/bin/nexus start
ExecStop=/opt/nexus/${nexus_version}/bin/nexus stop
User=nexus
Restart=on-abort
  
[Install]
WantedBy=multi-user.target
EOF

    # Activate the service
    sudo systemctl daemon-reload
    sudo systemctl enable nexus.service
    sudo systemctl start nexus.service
    echo "[SUCCESS] Nexus installed complete!" >> $LOG_INSTALL
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
        install_nexus
    else
        echo "[ERROR] This operating system is not supported." >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="nexus"
LOG_INSTALL='/tmp/install_nexus.log'
main

