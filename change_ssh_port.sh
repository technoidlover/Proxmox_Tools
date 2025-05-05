#!/bin/bash

# Set the new SSH port (replace 2222 with the desired port)
NEW_SSH_PORT=2222

# Update the SSH configuration file with the new port
echo "Updating SSH port in configuration file..."
sed -i "s/^#Port 22/Port $NEW_SSH_PORT/" /etc/ssh/sshd_config

# Restart the SSH service to apply the changes
echo "Restarting SSH service..."
systemctl restart sshd

# Update the firewall to allow traffic on the new SSH port
echo "Updating firewall to allow new SSH port..."
ufw allow $NEW_SSH_PORT/tcp
ufw delete allow 22/tcp

# Check the firewall status
echo "Checking firewall status..."
ufw status

# Print the new SSH port
echo "SSH is now running on port $NEW_SSH_PORT."

echo "Done!"
