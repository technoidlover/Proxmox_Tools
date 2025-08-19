# Proxmox Tools Collection

[![GitHub stars](https://img.shields.io/github/stars/technoidlover/Proxmox_Tools)](https://github.com/technoidlover/Proxmox_Tools/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/technoidlover/Proxmox_Tools)](https://github.com/technoidlover/Proxmox_Tools/network)
[![GitHub issues](https://img.shields.io/github/issues/technoidlover/Proxmox_Tools)](https://github.com/technoidlover/Proxmox_Tools/issues)
[![License](https://img.shields.io/github/license/technoidlover/Proxmox_Tools)](https://github.com/technoidlover/Proxmox_Tools/blob/main/LICENSE)

A comprehensive collection of bash scripts designed for **Proxmox VE 7.x and 8.x** administration, server setup, and system management. These tools help streamline common tasks in virtualized environments.

![ScreenShot](ScreenShot.png "Proxmox Tools Interface")

---

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Available Tools](#available-tools)
- [Installation](#installation)
- [Usage Guide](#usage-guide)
- [first_Setup.sh Guide](#first_setupsh-guide)
- [Module Descriptions](#module-descriptions)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- **Interactive Menu System**: Beautiful ASCII interface with centered display
- **Modular Design**: Individual scripts for specific tasks
- **Auto-Detection**: Intelligent detection of system configuration
- **Safety First**: Automatic backups and rollback capabilities
- **Real-time Monitoring**: System information and hardware monitoring
- **Network Configuration**: Automated network setup and IP management
- **Storage Management**: ZFS setup and disk management tools
- **Development Environment**: Quick setup for multiple programming languages

---

## Quick Start

### Super Quick Run (No Download Required)

```bash
# Run main menu directly
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/main.sh | sudo bash

# Or run specific tools directly:
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/first_Setup.sh | sudo bash
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/Set_IP_Static_LAN.sh | sudo bash
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/Hardware_info.sh | sudo bash
```

### 📥 Traditional Installation

```bash
# Clone the repository
git clone https://github.com/technoidlover/Proxmox_Tools.git

# Navigate to directory
cd Proxmox_Tools

# Make scripts executable
chmod +x *.sh

# Run the main menu
sudo ./main.sh
```

---

## Available Tools

| Script | Description | Category |
|--------|-------------|----------|
| **main.sh** | Interactive menu system for all tools | Main Interface |
| **first_Setup.sh** | Complete server setup with development environment | System Setup |
| **Set_IP_Static_LAN.sh** | Automatic static IP configuration from DHCP | Network |
| **Hardware_info.sh** | Comprehensive hardware monitoring and information | Monitoring |
| **Disk_setup.sh** | Automated ZFS disk setup and formatting | Storage |
| **Change_disk_name.sh** | Rename Proxmox storage pools | Storage |
| **change_ssh_port.sh** | Secure SSH port configuration | Security |
| **Turnoff_ipv6.sh** | Disable IPv6 with persistence | Network |

---

## Installation

### Method 1: Direct Download
```bash
wget -O proxmox_tools.zip https://github.com/technoidlover/Proxmox_Tools/archive/main.zip
unzip proxmox_tools.zip
cd Proxmox_Tools-main
```

### Method 2: Git Clone
```bash
git clone https://github.com/technoidlover/Proxmox_Tools.git
cd Proxmox_Tools
```

### Method 3: One-liner Setup
```bash
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/setup.sh | bash
```

---

## Usage Guide

### Quick Run Commands (One-liners)

| Script | Direct Run Command | Description |
|--------|-------------------|-------------|
| **Main Menu** | `curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/main.sh \| sudo bash` | Interactive menu for all tools |
| **Complete Setup** | `curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/first_Setup.sh \| sudo bash` | Full server setup with all modules |
| **Static IP Setup** | `curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/Set_IP_Static_LAN.sh \| sudo bash` | Convert DHCP to static IP |
| **Hardware Info** | `curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/Hardware_info.sh \| sudo bash` | System monitoring and info |
| **Disk Setup** | `curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/Disk_setup.sh \| sudo bash` | ZFS disk configuration |
| **Rename Storage** | `curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/Change_disk_name.sh \| sudo bash` | Rename Proxmox storage pools |
| **Change SSH Port** | `curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/change_ssh_port.sh \| sudo bash` | Secure SSH port change |
| **Disable IPv6** | `curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/Turnoff_ipv6.sh \| sudo bash` | Turn off IPv6 permanently |

### Traditional Usage (After Installation)

### 🎯 Main Interface
```bash
sudo ./main.sh
```
The main script provides an interactive menu to access all tools with a beautiful ASCII interface.

### 📦 Complete Server Setup
```bash
sudo ./first_Setup.sh
```
**Available Setup Modes:**
1. **Fresh Installation** - Complete setup from scratch
2. **Resume Installation** - Continue from previous state
3. **Custom Installation** - Select specific modules
4. **Bulk Installation** - Install all modules (skip errors)

### 🌐 Network Configuration
```bash
sudo ./Set_IP_Static_LAN.sh
```
**Auto-detects and configures:**
- Current interface (ens18, eth0, etc.)
- Current IP address from DHCP
- Current gateway
- Subnet mask
- Converts DHCP to static IP seamlessly

### 📊 Hardware Monitoring
```bash
sudo ./Hardware_info.sh
```
**Provides comprehensive information:**
- CPU model, cores, and temperature
- GPU detection (NVIDIA, AMD, Intel)
- RAM usage statistics
- Disk information and usage
- System uptime
- Interactive btop/htop launcher

### 💾 Storage Management
```bash
# Setup new disks with ZFS
sudo ./Disk_setup.sh

# Rename storage pools
sudo ./Change_disk_name.sh
```

### 🔒 Security Configuration
```bash
# Change SSH port securely
sudo ./change_ssh_port.sh

# Disable IPv6
sudo ./Turnoff_ipv6.sh
```

---

## first_Setup.sh Guide

The `first_Setup.sh` script is the most comprehensive tool in this collection, designed to transform a fresh Ubuntu/Debian/Proxmox installation into a fully configured development server. It's perfect for quickly setting up new VMs or containers.

### What Does It Do?

This script installs and configures:
- **System Updates**: Latest packages and security patches
- **QEMU Guest Agent**: VM integration with Proxmox host
- **Development Tools**: Node.js, Python, PHP, .NET, Bun.js
- **Databases**: MySQL, PostgreSQL, MongoDB
- **System Utilities**: htop, curl, wget, git, build tools
- **Network**: IPv6 disable, IP configuration
- **Monitoring**: neofetch, system info tools

### Usage Options

#### 1. Quick Start (Recommended)
```bash
# Run directly from GitHub
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/first_Setup.sh | sudo bash

# Or download and run
sudo ./first_Setup.sh
```

#### 2. Installation Modes

When you run the script, you'll see 4 options:

**Mode 1: Fresh Installation**
- Installs all modules from scratch
- Prompts for confirmation after each module
- Allows pause/resume functionality
- **Best for**: New servers, first-time setup

**Mode 2: Resume Installation**
- Continues from where you left off
- Uses saved state file
- Skips already completed modules
- **Best for**: Resuming interrupted installations

**Mode 3: Custom Installation**
- Choose specific modules to install
- Interactive module selection
- Skip unwanted components
- **Best for**: Selective installations, existing servers

**Mode 4: Bulk Installation**
- Installs all modules automatically
- Continues even if some modules fail
- No prompts, fully automated
- **Best for**: Automated deployments, scripts

### Module Breakdown

| Module | What It Installs | Time | Size |
|--------|------------------|------|------|
| **update_system** | System packages, security updates | 2-5 min | ~100MB |
| **install_qemu** | QEMU Guest Agent for VM integration | 1 min | ~5MB |
| **install_neofetch** | System information display tool | 30s | ~2MB |
| **check_ip** | Network validation (no install) | 10s | 0MB |
| **disable_ipv6** | IPv6 configuration disable | 10s | 0MB |
| **basic_utils** | htop, curl, wget, git, build-essential | 2-3 min | ~200MB |
| **install_node** | NVM + Node.js LTS | 3-5 min | ~150MB |
| **install_bun** | Bun.js runtime | 1-2 min | ~50MB |
| **install_php** | PHP CLI + Composer | 2-3 min | ~100MB |
| **install_python** | Python3, pip, venv | 1-2 min | ~50MB |
| **install_mysql** | MySQL Server (port 3307) | 3-5 min | ~200MB |
| **install_postgres** | PostgreSQL (port 5433) | 2-4 min | ~150MB |
| **install_mongodb** | MongoDB Community | 4-6 min | ~300MB |
| **install_dotnet** | .NET 7.0 SDK | 3-5 min | ~200MB |
| **create_env** | Database connection templates | 10s | 1KB |

**Total Installation Time**: 25-40 minutes  
**Total Disk Space**: ~1.5GB

### Important Notes

#### Custom Port Configuration
The script configures databases on non-standard ports to avoid conflicts:
- **MySQL**: Port 3307 (instead of 3306)
- **PostgreSQL**: Port 5433 (instead of 5432)
- **MongoDB**: Port 27017 (default)

#### State Management
- **Log File**: `~/server_setup_log.txt` - Complete installation log
- **State File**: `~/server_setup_state.txt` - Tracks completed modules
- **Environment File**: `~/server_env.env` - Database connection templates

#### Error Handling
- Each module runs independently
- Failed modules don't stop the entire process
- Detailed error logging for troubleshooting
- Resume capability from any point

### Examples

#### Example 1: Development Server Setup
```bash
# For a complete Node.js development server
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/first_Setup.sh | sudo bash
# Choose Mode 1, install all modules
```

#### Example 2: Database Server Only
```bash
# For database server setup only
sudo ./first_Setup.sh
# Choose Mode 3, select: update_system, basic_utils, install_mysql, install_postgres
```

#### Example 3: Resume After Network Issue
```bash
# If installation was interrupted
sudo ./first_Setup.sh
# Choose Mode 2 to resume from saved state
```

### Troubleshooting

**Common Issues:**

1. **Permission Denied**
   ```bash
   sudo chmod +x first_Setup.sh
   sudo ./first_Setup.sh
   ```

2. **Network Timeout**
   - Check internet connection
   - Resume with Mode 2 after fixing network

3. **Disk Space**
   - Ensure at least 2GB free space
   - Check with `df -h`

4. **Package Conflicts**
   - Remove conflicting packages first
   - Check logs in `~/server_setup_log.txt`

**Log Analysis:**
```bash
# Check installation progress
tail -f ~/server_setup_log.txt

# Check what modules completed
cat ~/server_setup_state.txt

# View database configurations
cat ~/server_env.env
```

---

## Module Descriptions

### 📦 first_Setup.sh Modules

| Module | Description | What It Installs |
|--------|-------------|-------------------|
| **update_system** | System updates | Latest packages and security updates |
| **install_qemu** | QEMU Guest Agent | VM integration tools |
| **install_neofetch** | System info display | Beautiful system information |
| **check_ip** | Network validation | Current IP and interface info |
| **disable_ipv6** | IPv6 configuration | Persistent IPv6 disable |
| **basic_utils** | Essential tools | htop, curl, wget, git, build-essential |
| **install_node** | Node.js environment | NVM + Latest LTS Node.js |
| **install_bun** | Bun.js runtime | Fast JavaScript runtime |
| **install_php** | PHP environment | PHP CLI + Composer |
| **install_python** | Python environment | Python3 + pip + venv |
| **install_mysql** | MySQL database | MySQL Server (port 3307) |
| **install_postgres** | PostgreSQL database | PostgreSQL (port 5433) |
| **install_mongodb** | MongoDB database | MongoDB Community Edition |
| **install_dotnet** | .NET SDK | .NET 7.0 SDK |
| **create_env** | Environment file | Database connection templates |

### 🌐 Network Tools Features

#### Set_IP_Static_LAN.sh
- **Auto-detection**: Automatically detects current network configuration
- **Validation**: IP address format validation
- **Safety**: Creates backup of netplan configuration
- **Testing**: Validates configuration before applying
- **Rollback**: Automatic rollback on failure
- **Connectivity**: Tests internet connection after setup

#### Turnoff_ipv6.sh
- **Runtime disable**: Immediate IPv6 shutdown
- **Persistent**: Survives reboots
- **MOTD integration**: Shows system information

### 💾 Storage Management

#### Disk_setup.sh
- **ZFS pools**: Creates optimized ZFS storage
- **Compression**: Enables LZ4 compression
- **Proxmox integration**: Automatically adds to Proxmox storage
- **Multi-disk**: Handles multiple disks automatically

#### Change_disk_name.sh
- **Interactive selection**: Choose from existing storage pools
- **Validation**: Prevents naming conflicts
- **Safe operation**: Validates before renaming

---

## Quick Examples & Common Use Cases

### Most Common Commands

```bash
# Quick server setup (most popular)
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/first_Setup.sh | sudo bash

# Fix network issues - convert DHCP to static IP
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/Set_IP_Static_LAN.sh | sudo bash

# Check system health and hardware
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/Hardware_info.sh | sudo bash
```

### Advanced One-liners

```bash
# Download and run main menu with logging
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/main.sh | sudo tee ~/proxmox_tools.log | sudo bash

# Chain multiple scripts
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/Turnoff_ipv6.sh | sudo bash && \
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/Set_IP_Static_LAN.sh | sudo bash

# Download specific script for later use
curl -sSL https://raw.githubusercontent.com/technoidlover/Proxmox_Tools/main/first_Setup.sh -o setup.sh
chmod +x setup.sh
sudo ./setup.sh
```

### Pro Tips

- **Always use `sudo`** for system-level changes
- **Test on non-production systems** first
- **Check logs** in `~/server_setup_log.txt` for troubleshooting
- **Use `-sSL` flags** with curl for silent, secure, and follow redirects
- **Backup important configs** before running scripts

### FAQ - Quick Run

**Q: Is it safe to run scripts directly from GitHub?**
A: Yes, using `https://raw.githubusercontent.com` is safe. The scripts are the same as in the repository and are executed with the same permissions you would give them locally.

**Q: What if I don't have internet during execution?**
A: Some scripts download packages, so internet is required. For offline use, clone the repository first.

**Q: Can I modify scripts before running?**
A: For quick modifications, download first: `curl -sSL [URL] -o script.sh`, edit, then run `sudo bash script.sh`

**Q: How to run with custom parameters?**
A: Download the script and modify variables at the top, or clone the repo for full customization.

---

## Requirements

### System Requirements
- **OS**: Ubuntu 20.04+, Debian 11+, Proxmox VE 7.x/8.x
- **Architecture**: x86_64 (amd64)
- **Memory**: Minimum 1GB RAM
- **Storage**: 10GB free space

### Software Dependencies
- **bash** (≥ 4.0)
- **sudo** privileges
- **curl** or **wget**
- **systemctl** (systemd)

### Network Requirements
- Internet connection for package downloads
- Root/sudo access for system modifications

---

## 🔍 Troubleshooting

### Common Issues

#### Permission Denied
```bash
chmod +x *.sh
sudo ./script_name.sh
```

#### Network Configuration Issues
```bash
# Check current network status
ip addr show
ip route show

# Reset network if needed
sudo netplan apply
```

#### Storage Issues
```bash
# Check available disks
lsblk
pvesm status
```

### Logs and State Files
- **Setup log**: `~/server_setup_log.txt`
- **State file**: `~/server_setup_state.txt`
- **Environment**: `~/server_env.env`

---

## Contributing

We welcome contributions! Here's how you can help:

### Bug Reports
- Use GitHub Issues
- Include system information
- Provide error logs
- Describe reproduction steps

### Feature Requests
- Open an issue with enhancement label
- Describe the use case
- Explain expected behavior

### Pull Requests
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Documentation
- Improve README
- Add code comments
- Create usage examples
- Write tutorials

---

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- **Proxmox Team** - For the excellent virtualization platform
- **Community Contributors** - For feedback and improvements
- **Open Source Projects** - For the tools and libraries used

---

## Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/technoidlover/Proxmox_Tools/issues)
- **Discussions**: [Community discussions](https://github.com/technoidlover/Proxmox_Tools/discussions)
- **Wiki**: [Detailed documentation](https://github.com/technoidlover/Proxmox_Tools/wiki)

---

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=technoidlover/Proxmox_Tools&type=Date)](https://star-history.com/#technoidlover/Proxmox_Tools&Date)

---

<div align="center">

**Made with ❤️ by [technoidlover](https://github.com/technoidlover)**

**Star this repository if you find it helpful!**

</div>

