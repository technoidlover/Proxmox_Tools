#!/bin/bash

set -e

ZABBIX_DEB="zabbix-release_latest_6.0+ubuntu22.04_all.deb"
ZABBIX_URL="http://nodesign.vn/$ZABBIX_DEB"

echo "==> Download Zabbix release package..."
wget -q --show-progress "$ZABBIX_URL"

echo "==> Install Zabbix repository..."
sudo dpkg -i "$ZABBIX_DEB"

echo "==> Update apt cache..."
sudo apt update -y

echo "==> Install Zabbix agent..."
sudo apt install -y zabbix-agent

echo "==> Enable & restart Zabbix agent..."
sudo systemctl enable zabbix-agent
sudo systemctl restart zabbix-agent

echo "==> Check Zabbix agent status..."
sudo systemctl status zabbix-agent --no-pager

echo "✅ Zabbix Agent installation completed successfully."
