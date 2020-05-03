#!/bin/bash 
# This script install bitbucket in your RHEL/Centos7 System

function prepare_env {
    # Update packages
    sudo yum update -y && yum install -y htop nc
    
    # Install openjdk-1.8
    sudo yum -y install java-1.8.0-openjdk.x86_64 

    cp /etc/profile /etc/profile_backup
    echo 'export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk' | sudo tee -a /etc/profile
    echo 'export JRE_HOME=/usr/lib/jvm/jre' | sudo tee -a /etc/profile
    echo 'export BITBUCKET_HOME=/opt/bitbucket-home' | sudo tee -a /etc/profile
    # Install git 2.x
    # sudo yum -y install  https://centos7.iuscommunity.org/ius-release.rpm
    # sudo yum -y install  git2u-all
    sudo yum install -y git-2* 
}

function install_bitbucket {
    sudo mkdir -p $BITBUCKET_FOLDER $BITBUCKET_HOME/shared
    curl -LO https://www.atlassian.com/software/stash/downloads/binary/${bitbucket_version}.tar.gz
    sudo tar -xzf ${bitbucket_version}.tar.gz -C /opt/bitbucket --strip-components=1 && rm -f ${bitbucket_version}.tar.gz

    # Uncomment umask setting, 'others' be denied access for security reasons.
    sudo sed -i 's/# umask 0027/umask 0027/g' /opt/bitbucket/bin/_start-webapp.sh

    # Create user Bitbụcket 
    sudo /usr/sbin/useradd --create-home --comment "Account for running Bitbucket" --shell /bin/bash atlbitbucket

    sudo chown -R atlbitbucket /opt/bitbucket*
    sudo chmod -R u=rwx,go-rwx  /opt/bitbucket*
}

function run_as_service {
    # Run bitbucket as a service
    sudo touch /etc/systemd/system/bitbucket.service
    sudo chmod 664 /etc/systemd/system/bitbucket.service

    # Create systemd service
    cat > /etc/systemd/system/bitbucket.service << EOF
[Unit]
Description=Atlassian Bitbucket Server Service
After=syslog.target network.target
 
[Service]
Type=forking
User=atlbitbucket
Environment=BITBUCKET_HOME=/opt/bitbucket-home
Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
ExecStart=/opt/bitbucket/bin/start-bitbucket.sh
ExecStop=/opt/bitbucket/bin/stop-bitbucket.sh
 
[Install]
WantedBy=multi-user.target
EOF



    # Activate the service
    sudo systemctl daemon-reload
    sudo systemctl enable bitbucket.service
    sudo systemctl start bitbucket.service
    echo "[SUCCESS] bitbucket installed complete!" >> $LOG_INSTALL
}

function config_bitbucket {
    # Config connect to database
    if [ -d "/opt/bitbucket-home/shared/" ];
    then
        echo "Directory /opt/bitbucket-home/shared/ exists."
        sudo cp /tmp/bitbucket.properties /opt/bitbucket-home/shared/
        sudo chown -R atlbitbucket:atlbitbucket /opt/bitbucket-home/shared/bitbucket.properties
        sudo chmod 640 /opt/bitbucket-home/shared/bitbucket.properties
    fi
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
        prepare_env && install_bitbucket && config_bitbucket && run_as_service
    else
        echo "[ERROR] This operating system is not supported." >> $LOG_INSTALL
    fi
}

BITBUCKET_FOLDER="/opt/bitbucket"
BITBUCKET_HOME="/opt/bitbucket-home"
OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="bitbucket"
LOG_INSTALL='/tmp/install_bitbucket.log'
main
