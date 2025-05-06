#!/bin/bash

# Disable IPv6 at runtime
echo "Disabling IPv6 at runtime..."
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# Persist the settings in /etc/sysctl.conf
echo "Persisting IPv6 disable settings..."
cat <<EOF >> /etc/sysctl.conf

# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

# Apply the new settings
sysctl -p

echo "IPv6 has been disabled."
