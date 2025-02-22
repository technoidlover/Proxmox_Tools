#!/bin/bash

# Function to rename a storage
rename_storage() {
    local old_name=$1
    local new_name=$2

    echo "🔧 Renaming storage: $old_name to $new_name..."

    # Check if the new name already exists
    if pvesm status | grep -q "^$new_name "; then
        echo "❌ Error: A storage with the name '$new_name' already exists."
        return
    fi

    # Rename the storage
    pvesm rename $old_name $new_name

    if [ $? -eq 0 ]; then
        echo "✅ Storage '$old_name' has been renamed to '$new_name'."
    else
        echo "❌ Failed to rename storage '$old_name'."
    fi
}

# Get a list of all storages
STORAGES=($(pvesm status | awk 'NR>1 {print $1}'))
TOTAL_STORAGES=${#STORAGES[@]}

# Check if there are any storages
if [ -z "$STORAGES" ]; then
    echo "❌ No storages found."
    exit 1
fi

# Display the list of storages with numbers
echo "📌 List of available storages:"
for i in "${!STORAGES[@]}"; do
    echo "  $((i+1)). ${STORAGES[$i]}"
done

# Prompt the user to select a storage
read -p "Enter the number of the storage you want to rename (1-$TOTAL_STORAGES): " STORAGE_INDEX

# Validate the selection
if [[ "$STORAGE_INDEX" =~ ^[0-9]+$ ]] && (( STORAGE_INDEX >= 1 && STORAGE_INDEX <= TOTAL_STORAGES )); then
    OLD_NAME="${STORAGES[$((STORAGE_INDEX-1))]}"
else
    echo "❌ Invalid selection. Please try again."
    exit 1
fi

# Prompt the user to enter the new name
read -p "Enter the new name for '$OLD_NAME': " NEW_NAME

# Validate the new name
if [ -z "$NEW_NAME" ]; then
    echo "❌ Error: The new name cannot be empty."
    exit 1
fi

# Rename the storage
rename_storage $OLD_NAME $NEW_NAME