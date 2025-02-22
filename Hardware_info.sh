#!/bin/bash

# Function to install required tools silently
install_tools() {
    if ! command -v lsb_release &> /dev/null; then
        echo "📥 Installing lsb-release (this may take a moment)..."
        sudo apt update > /dev/null 2>&1
        sudo apt install -y lsb-release > /dev/null 2>&1
    fi

    if ! command -v btop &> /dev/null; then
        echo "📥 Installing btop (this may take a moment)..."
        sudo apt update > /dev/null 2>&1
        sudo apt install -y btop > /dev/null 2>&1
    fi

    if ! command -v htop &> /dev/null; then
        echo "📥 Installing htop (this may take a moment)..."
        sudo apt update > /dev/null 2>&1
        sudo apt install -y htop > /dev/null 2>&1
    fi

    if ! command -v sensors &> /dev/null; then
        echo "📥 Installing lm-sensors (this may take a moment)..."
        sudo apt update > /dev/null 2>&1
        sudo apt install -y lm-sensors > /dev/null 2>&1
        sudo sensors-detect --auto > /dev/null 2>&1
    fi
}

# Function to detect GPU
detect_gpu() {
    if lspci | grep -i "VGA" | grep -i "NVIDIA" &> /dev/null; then
        GPU_MODEL=$(lspci | grep -i "VGA" | grep -i "NVIDIA" | cut -d ":" -f 3 | xargs)
        if command -v nvidia-smi &> /dev/null; then
            GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)
            echo "🎮 GPU: $GPU_MODEL | Temperature: ${GPU_TEMP}°C"
        else
            echo "🎮 GPU: $GPU_MODEL (Driver not installed)"
        fi
    elif lspci | grep -i "VGA" | grep -i "AMD" &> /dev/null; then
        GPU_MODEL=$(lspci | grep -i "VGA" | grep -i "AMD" | cut -d ":" -f 3 | xargs)
        echo "🎮 GPU: $GPU_MODEL"
    elif lspci | grep -i "VGA" | grep -i "Intel" &> /dev/null; then
        GPU_MODEL=$(lspci | grep -i "VGA" | grep -i "Intel" | cut -d ":" -f 3 | xargs)
        echo "🎮 GPU: $GPU_MODEL"
    else
        echo "🎮 GPU: Not detected"
    fi
}

# Function to display system information
display_system_info() {
    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    echo -e "${BLUE}===================== SYSTEM INFORMATION =====================${NC}"

    # Display OS information
    echo -e "\n${GREEN}📌 Operating System:${NC}"
    if command -v lsb_release &> /dev/null; then
        echo -e "$(lsb_release -d | awk -F"\t" '{print $2}') | $(uname -r)"
    else
        echo -e "$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d "=" -f 2 | tr -d '"') | $(uname -r)"
    fi

    # Display CPU information
    echo -e "\n${GREEN}💻 CPU:${NC}"
    echo -e "Model: $(lscpu | grep "Model name" | awk -F":" '{print $2}' | xargs)"
    echo -e "Cores: $(nproc)"
    if command -v sensors &> /dev/null; then
        CPU_TEMP=$(sensors | grep "Package id" | awk '{print $4}' 2>/dev/null)
        if [ -n "$CPU_TEMP" ]; then
            echo -e "Temperature: $CPU_TEMP"
        else
            echo -e "Temperature: Not available"
        fi
    else
        echo -e "Temperature: lm-sensors not installed"
    fi

    # Display GPU information
    echo -e "\n${GREEN}🎮 GPU:${NC}"
    detect_gpu

    # Display RAM information
    echo -e "\n${GREEN}🧠 RAM:${NC}"
    RAM_TOTAL=$(free -h | grep "Mem" | awk '{print $2}')
    RAM_USED=$(free -h | grep "Mem" | awk '{print $3}')
    RAM_FREE=$(free -h | grep "Mem" | awk '{print $4}')
    echo -e "Total: $RAM_TOTAL | Used: $RAM_USED | Free: $RAM_FREE"

    # Display disk information
    echo -e "\n${GREEN}💾 Disks and Partitions:${NC}"
    lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT | grep -v "loop" | awk '{print $1, $2, $3, $4}' | column -t

    echo -e "\n${GREEN}📊 Disk Usage:${NC}"
    df -h --output=source,size,used,avail,pcent | grep -v "tmpfs" | column -t

    # Display number of disks
    echo -e "\n${GREEN}🔢 Number of Disks:${NC}"
    echo -e "$(lsblk -d | grep -c "disk") disks detected"

    # Display uptime
    echo -e "\n${GREEN}⏰ Uptime:${NC}"
    echo -e "$(uptime -p)"

    echo -e "${BLUE}============================================================${NC}"
}

# Function to launch monitor
launch_monitor() {
    while true; do
        echo -e "\n${YELLOW}Choose an option:${NC}"
        echo -e "1. Launch btop"
        echo -e "2. Launch htop"
        echo -e "3. Exit"
        read -p "Enter your choice (1/2/3): " CHOICE

        case $CHOICE in
            1)
                if command -v btop &> /dev/null; then
                    echo -e "\n🚀 Launching btop..."
                    btop
                    break
                else
                    echo -e "\n❌ btop is not installed. Please install it first."
                fi
                ;;
            2)
                if command -v htop &> /dev/null; then
                    echo -e "\n🚀 Launching htop..."
                    htop
                    break
                else
                    echo -e "\n❌ htop is not installed. Please install it first."
                fi
                ;;
            3)
                echo -e "\n👋 Exiting..."
                exit 0
                ;;
            *)
                echo -e "\n❌ Invalid choice. Please try again."
                ;;
        esac
    done
}

# Main script
install_tools
display_system_info
launch_monitor