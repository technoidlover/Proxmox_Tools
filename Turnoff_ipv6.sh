#!/bin/bash

# Disable IPv6 at runtime
echo "Disabling IPv6 at runtime..."
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# Persist the settings in /etc/sysctl.conf
echo "Persisting IPv6 disable settings..."
grep -q "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf || cat <<EOF >> /etc/sysctl.conf

# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

# Apply the new settings
echo "Applying sysctl settings..."
sysctl -p

# Show MOTD immediately (simulate SSH login message)
echo ""
echo "📋 Simulating MOTD output:"
run-parts /etc/update-motd.d/

echo ""
echo "✅ IPv6 has been disabled and MOTD info displayed."
