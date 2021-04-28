#!/bin/bash 
# This script install Jira in your RHEL/Centos7 System

function install_bamboo {
    # Update packages
    sudo yum update -y
    sudo yum install -y htop nc

    # Install openjdk-1.8
    sudo yum -y install java-1.8.0-openjdk.x86_64

    cp /etc/profile /etc/profile_backup
    echo 'export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk' | sudo tee -a /etc/profile
    echo 'export JRE_HOME=/usr/lib/jvm/jre' | sudo tee -a /etc/profile

    # Download Bamboo
    sudo mkdir /opt/bamboo /opt/bamboo-home
    curl -LO https://www.atlassian.com/software/bamboo/downloads/binary/${bamboo_version}.tar.gz 
    tar -xzf ${bamboo_version}.tar.gz -C /opt/bamboo --strip-components=1 && rm -f ${bamboo_version}.tar.gz
    
    sudo /usr/sbin/useradd --create-home --comment "Account for running Bamboo Software" --shell /bin/bash bamboo
    chown -R bamboo /opt/bamboo*
    chmod -R u=rwx,go-rwx  /opt/bamboo*
    echo 'export BAMBOO_HOME=/opt/bamboo-home/' | sudo tee -a /etc/profile
    source /etc/profile

    sed -i 's/#bamboo.home.*/bamboo.home=\/opt\/bamboo-home/g' /opt/bamboo/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties

    # Run bamboo as a service
    sudo touch /lib/systemd/system/bamboo.service
    sudo chmod 664 /lib/systemd/system/bamboo.service
    
    # Create systemd service
    cat > /lib/systemd/system/bamboo.service << EOF
[Unit] 
Description=Atlassian Bamboo
After=network.target
[Service] 
Type=forking
User=bamboo
ExecStart=/opt/bamboo/bin/start-bamboo.sh
ExecStop=/opt/bamboo/bin/stop-bamboo.sh
SuccessExitStatus=143
[Install] 
WantedBy=multi-user.target
EOF

    # Activate the service
    sudo systemctl daemon-reload
    sudo systemctl enable bamboo.service
    sudo systemctl start bamboo.service
    echo "[SUCCESS] Bamboo installed complete!" >> $LOG_INSTALL
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
        install_bamboo
    else
        echo "[ERROR] This operating system is not supported." >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="bamboo"
LOG_INSTALL='/tmp/install_bamboo.log'
main
