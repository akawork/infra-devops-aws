#!/bin/bash 
# This script install Prometheus in your RHEL/Centos7 System

function install_prometheus {
    # Update package
    sudo yum update -y
    sudo yum install -y htop nc

    # Disable SELinux
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
    curl -LO https://github.com/prometheus/prometheus/releases/download/v${prometheus_version}/prometheus-${prometheus_version}.linux-amd64.tar.gz

    # Add a Prometheus user
    useradd --no-create-home --shell /bin/false prometheus
    
    mkdir /etc/prometheus /var/lib/prometheus
    chown prometheus:prometheus /etc/prometheus /var/lib/prometheus

    tar -xzf prometheus-${prometheus_version}.linux-amd64.tar.gz && rm -f prometheus-${prometheus_version}.linux-amd64.tar.gz
    mv prometheus-${prometheus_version}.linux-amd64 prometheuspackage

    sudo cp prometheuspackage/prometheus /usr/local/bin/
    sudo cp prometheuspackage/promtool /usr/local/bin/

    sudo chown prometheus:prometheus /usr/local/bin/prometheus
    sudo chown prometheus:prometheus /usr/local/bin/promtool

    sudo cp -r prometheuspackage/consoles /etc/prometheus
    sudo cp -r prometheuspackage/console_libraries /etc/prometheus

    sudo chown -R prometheus:prometheus /etc/prometheus/consoles
    sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

    # Copy config file
    sudo cp /tmp/prometheus.yml /etc/prometheus/prometheus.yml
    sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

    # Create systemd service
    cat > /etc/systemd/system/prometheus.service << EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

    # Activate the service
    sudo systemctl daemon-reload
    sudo systemctl start prometheus
    sudo systemctl enable prometheus
    echo "[SUCCESS] Prometheus installed complete!" >> $LOG_INSTALL
}

function main {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root"  >> $LOG_INSTALL
        exit 1
    fi

    if [[ $OS == "centos" || $OS == "amazon" ]];
    then
        install_prometheus
        echo "[SUCCESS] Prometheus installed complete!"
    else
        echo "[ERROR] This operating system is not supported." >> $LOG_INSTALL
    fi
}

OS=$( cat /etc/*-release | grep 'NAME' | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|centos|fedora|amazon)' | uniq )
SERVICE="prometheus"
LOG_INSTALL='/tmp/install_prometheus.log'
main
