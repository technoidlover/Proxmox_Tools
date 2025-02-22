#!/bin/bash

# Function to format a disk with ZFS
format_disk_zfs() {
    local disk=$1
    local storage_name=$2

    echo "🔧 Formatting disk: /dev/${disk}..."

    # Wipe the disk
    wipefs --all --force /dev/${disk}

    # Create a ZFS pool
    echo "Creating ZFS pool: ${storage_name}..."
    zpool create -f -o ashift=12 ${storage_name} /dev/${disk}

    # Set compression (optional, improves performance for HDD)
    zfs set compression=lz4 ${storage_name}

    # Add the ZFS pool to Proxmox storage
    echo "Adding ZFS pool ${storage_name} to Proxmox storage..."
    pvesm add zfspool ${storage_name} --pool ${storage_name} --content images,iso,vztmpl

    echo "✅ Disk /dev/${disk} has been formatted and added as ZFS storage: ${storage_name}"
}

# Get a list of all disks (excluding system disks)
DISKS=$(lsblk -nd --output NAME,SIZE | grep -vE "sda|sr0|loop" | sort -k2 -hr | awk '{print $1}')

# Check if there are any disks to format
if [ -z "$DISKS" ]; then
    echo "❌ No additional disks found. Please connect new disks and try again."
    exit 1
fi

# Counter for storage naming
STORAGE_COUNT=1

# Loop through each disk and format it
for DISK in $DISKS; do
    # Assign a storage name (e.g., Storage1, Storage2, etc.)
    STORAGE_NAME="Storage${STORAGE_COUNT}"

    # Format the disk with ZFS
    format_disk_zfs $DISK $STORAGE_NAME

    # Increment the storage counter
    STORAGE_COUNT=$((STORAGE_COUNT + 1))
done

echo "🎉 All disks have been formatted and added as ZFS storage!"