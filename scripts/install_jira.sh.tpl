#!/bin/bash 
# This script install Jira in your RHEL/Centos7 System

function install_jira {
    # Update packages
    sudo yum update -y
    sudo yum install -y htop nc

    # Install openjdk-1.8
    sudo yum -y install java-1.8.0-openjdk.x86_64

    cp /etc/profile /etc/profile_backup
    echo 'export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk' | sudo tee -a /etc/profile
    echo 'export JRE_HOME=/usr/lib/jvm/jre' | sudo tee -a /etc/profile

    # Download jira
    sudo mkdir /opt/jira /opt/jira-home
    curl -LO https://www.atlassian.com/software/jira/downloads/binary/${jira_version}.tar.gz 
    tar -xzf ${jira_version}.tar.gz -C /opt/jira --strip-components=1 && rm -f ${jira_version}.tar.gz
    
    sudo /usr/sbin/useradd --create-home --comment "Account for running Jira Software" --shell /bin/bash jira
    chown -R jira /opt/jira*
    chmod -R u=rwx,go-rwx  /opt/jira*
    echo 'export JIRA_HOME=/opt/jira-home/' | sudo tee -a /etc/profile
    source /etc/profile

    sed -i 's/jira.home.*/jira.home=\/opt\/jira-home/g' /opt/jira/atlassian-jira/WEB-INF/classes/jira-application.properties

    # Run jira as a service
    sudo touch /lib/systemd/system/jira.service
    sudo chmod 664 /lib/systemd/system/jira.service
    
    # Create systemd service
    cat > /lib/systemd/system/jira.service << EOF
[Unit] 
Description=Atlassian Jira
After=network.target
[Service] 
Type=forking
User=jira
PIDFile=/opt/jira/work/catalina.pid
ExecStart=/opt/jira/bin/start-jira.sh
ExecStop=/opt/jira/bin/stop-jira.sh
[Install] 
WantedBy=multi-user.target 
EOF

    # Config connect to database
    sudo cp /tmp/dbconfig.xml /opt/jira-home
    sudo chown jira:jira /opt/jira-home/dbconfig.xml
    sudo chmod 640 /opt/jira-home/dbconfig.xml

    # Activate the service
    sudo systemctl daemon-reload
    sudo systemctl enable jira.service
    sudo systemctl start jira.service
    echo "[SUCCESS] Jira installed complete!" >> $LOG_INSTALL
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
        install_jira
    else
        echo "[ERROR] This operating system is not supported." >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="jira"
LOG_INSTALL='/tmp/install_jira.log'
main
