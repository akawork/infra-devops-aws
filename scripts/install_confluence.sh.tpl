#!/bin/bash 
# This script install confluence in your RHEL/Centos7 System

function install_confluence {
    # Update packages
    sudo yum update -y && sudo yum install -y nc htop

    # Install openjdk-1.8
    sudo yum -y install java-1.8.0-openjdk.x86_64

    cp /etc/profile /etc/profile_backup
    echo 'export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk' | sudo tee -a /etc/profile
    echo 'export JRE_HOME=/usr/lib/jvm/jre' | sudo tee -a /etc/profile

    # Download confluence
    sudo mkdir /opt/confluence /opt/confluence-home
    curl -LO https://www.atlassian.com/software/confluence/downloads/binary/${confluence_version}.tar.gz
    sudo tar -xzf ${confluence_version}.tar.gz -C /opt/confluence --strip-components=1 && rm -f ${confluence_version}.tar.gz
    
    sudo /usr/sbin/useradd --create-home --comment "Account for running Confluence" --shell /bin/bash confluence

    sudo chown -R confluence /opt/confluence*
    sudo chmod -R u=rwx,go-rwx  /opt/confluence*

    sudo sed -i 's/# confluence.home.*/confluence.home=\/opt\/confluence-home/g' /opt/confluence/confluence/WEB-INF/classes/confluence-init.properties

    # Run confluence as a service
    sudo touch /lib/systemd/system/confluence.service
    sudo chmod 664 /lib/systemd/system/confluence.service
    
    # Create systemd service
    cat > /lib/systemd/system/confluence.service << EOF
[Unit] 
Description=Atlassian Confluence
After=network.target

[Service] 
Type=forking
User=confluence
PIDFile=/opt/confluence/work/catalina.pid
ExecStart=/opt/confluence/bin/start-confluence.sh
ExecStop=/opt/confluence/bin/stop-confluence.sh
TimeoutSec=200
LimitNOFILE=4096
LimitNPROC=4096

[Install] 
WantedBy=multi-user.target 
EOF


    # Activate the service
    sudo systemctl daemon-reload
    sudo systemctl enable confluence.service
    sudo systemctl start confluence.service
    echo "[SUCCESS] confluence installed complete!" >> $LOG_INSTALL
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
        install_confluence
    else
        echo "[ERROR] This operating system is not supported." >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="confluence"
LOG_INSTALL='/tmp/install_confluence.log'
main
