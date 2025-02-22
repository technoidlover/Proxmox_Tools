#!/bin/bash

# General configuration
DEFAULT_STORAGE="local-lvm"
ISO_URL="https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
ISO_PATH="/var/lib/vz/template/iso/ubuntu-server.iso"
NETWORK_BRIDGE="vmbr0"

# Get the list of available storages
STORAGE_LIST=($(pvesm status | awk 'NR>1 {print $1}'))
TOTAL_STORAGE=${#STORAGE_LIST[@]}

# Display the list of storages with numbers
echo "📌 List of available storages on Proxmox:"
for i in "${!STORAGE_LIST[@]}"; do
    echo "  $((i+1)). ${STORAGE_LIST[$i]}"
done

# Select storage by number
echo "📌 Default storage: $DEFAULT_STORAGE"
read -p "Enter the storage number (1-$TOTAL_STORAGE, press Enter to keep default): " STORAGE_INDEX

# Validate the selection
if [[ "$STORAGE_INDEX" =~ ^[0-9]+$ ]] && (( STORAGE_INDEX >= 1 && STORAGE_INDEX <= TOTAL_STORAGE )); then
    STORAGE="${STORAGE_LIST[$((STORAGE_INDEX-1))]}"
else
    STORAGE="$DEFAULT_STORAGE"
fi

echo "✅ Selected storage: $STORAGE"

# List of VMs and their configurations
declare -A VM_CONFIGS=(
    ["gitlab"]="id=200 cpu=2 cores=4 ram=10240 disk=500G ip=192.168.1.20"
    ["nextcloud"]="id=201 cpu=2 cores=4 ram=8192 disk=1000G ip=192.168.1.21"
    ["email"]="id=202 cpu=1 cores=2 ram=6144 disk=500G ip=192.168.1.22"
    ["proxy"]="id=203 cpu=1 cores=2 ram=4096 disk=50G ip=192.168.1.23"
)

# Check and download the ISO if it doesn't exist
if [ ! -f "$ISO_PATH" ]; then
    echo "📥 Downloading Ubuntu ISO..."
    wget -O "$ISO_PATH" "$ISO_URL"
fi

# Function to create a VM
create_vm() {
    local name="$1"
    local config="${VM_CONFIGS[$name]}"

    # Extract configuration parameters
    eval "$config"

    echo "🚀 Creating VM: $name (ID: $id, CPU: $cpu x $cores, RAM: ${ram}MB, Disk: $disk, IP: $ip)"

    # Stop and destroy the VM if it already exists
    qm stop $id 2>/dev/null
    qm destroy $id 2>/dev/null

    # Create the VM
    qm create $id --name $name --memory $ram --cores $cores --cpu cputype=host --net0 virtio,bridge=$NETWORK_BRIDGE
    qm set $id --scsi0 $STORAGE:$disk
    qm set $id --ide2 $STORAGE:iso/ubuntu-server.iso,media=cdrom
    qm set $id --boot c --bootdisk scsi0
    qm set $id --serial0 socket --vga serial0

    # Configure Cloud-Init
    echo "📄 Configuring Cloud-Init for $name..."
    qm set $id --ide3 $STORAGE:cloudinit
    qm set $id --ipconfig0 ip=$ip/24,gw=192.168.1.1
    qm set $id --ciuser hng --cipassword hng06062024
    qm set $id --searchdomain local --nameserver 8.8.8.8
    qm set $id --ciupgrade 0  # Disable auto-update
    qm set $id --sshkeys ~/.ssh/id_rsa.pub  # If SSH key is available

    # Start the VM
    qm start $id
    echo "✅ VM $name is ready!"
}

# Create all VMs
for vm in "${!VM_CONFIGS[@]}"; do
    create_vm "$vm"
done

echo "🎉 All done! Connect to the VMs to install the services."