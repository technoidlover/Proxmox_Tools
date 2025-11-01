#!/bin/bash
# === AUTO INSTALL QEMU GUEST AGENT ===
# Works for Debian, Ubuntu, CentOS, AlmaLinux, Rocky

echo "🚀 Installing QEMU Guest Agent..."

# Detect OS
if [ -f /etc/debian_version ]; then
    apt update -y
    apt install -y qemu-guest-agent
    systemctl enable qemu-guest-agent
    systemctl start qemu-guest-agent
elif [ -f /etc/redhat-release ]; then
    yum install -y qemu-guest-agent || dnf install -y qemu-guest-agent
    systemctl enable qemu-guest-agent
    systemctl start qemu-guest-agent
else
    echo "⚠️ Unsupported OS. Please install manually."
    exit 1
fi

systemctl status qemu-guest-agent --no-pager
echo "✅ QEMU Guest Agent installation complete!"
