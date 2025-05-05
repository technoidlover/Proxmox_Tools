#!/bin/bash

# Prompt for the new SSH port
read -p "Enter the new SSH port: " NEW_SSH_PORT

# Check if the port number is valid (between 1024 and 65535)
if [[ $NEW_SSH_PORT -lt 1024 || $NEW_SSH_PORT -gt 65535 ]]; then
  echo "Invalid port number. Please enter a port number between 1024 and 65535."
  exit 1
fi

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
