#!/bin/bash

# Get the current SSH port from the configuration
CURRENT_SSH_PORT=$(grep "^Port" /etc/ssh/sshd_config | awk '{print $2}')

# If the current port is not found, default to port 22
if [ -z "$CURRENT_SSH_PORT" ]; then
    CURRENT_SSH_PORT=22
fi

# Display the current SSH port
echo "Current SSH port is: $CURRENT_SSH_PORT"

# Prompt for the new SSH port
read -p "Enter the new SSH port: " NEW_SSH_PORT

# Check if the port number is valid (between 1024 and 65535)
if [[ $NEW_SSH_PORT -lt 1024 || $NEW_SSH_PORT -gt 65535 ]]; then
  echo "Invalid port number. Please enter a port number between 1024 and 65535."
  exit 1
fi

# Update the SSH configuration file with the new port
echo "Updating SSH port in configuration file..."
sed -i "s/^Port $CURRENT_SSH_PORT/Port $NEW_SSH_PORT/" /etc/ssh/sshd_config

# Restart the SSH service to apply the changes
echo "Restarting SSH service..."
systemctl restart sshd

# Remove the old SSH port from the firewall
echo "Removing old SSH port ($CURRENT_SSH_PORT) from firewall..."
ufw delete allow $CURRENT_SSH_PORT/tcp

# Update the firewall to allow traffic on the new SSH port
echo "Updating firewall to allow new SSH port ($NEW_SSH_PORT)..."
ufw allow $NEW_SSH_PORT/tcp

# Check the firewall status
echo "Checking firewall status..."
ufw status

# Print the new SSH port
echo "SSH is now running on port $NEW_SSH_PORT."

echo "Done!"
