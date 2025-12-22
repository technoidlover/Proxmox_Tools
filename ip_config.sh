#!/bin/bash

# Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
   echo "Vui lòng chạy với sudo!"
   exit 1
fi

# 1. Lấy thông tin hệ thống hiện tại
# Tìm interface đang có kết nối internet/LAN (ưu tiên gateway)
LAN_IF=$(ip route | awk '/^default/ {print $5}' | head -n1)
if [ -z "$LAN_IF" ]; then
    # Nếu không có default route, lấy interface vật lý đầu tiên (loại bỏ 'lo')
    LAN_IF=$(ip -br link show | grep UP | awk '{print $1}' | grep -v lo | head -n1)
fi

# Lấy Gateway hiện tại từ bảng route
CURRENT_GW=$(ip route | grep default | awk '{print $3}' | head -n1)
# Nếu không thấy Gateway, tự suy luận từ IP hiện tại (ví dụ .1)
if [ -z "$CURRENT_GW" ]; then
    CURRENT_IP=$(ip addr show $LAN_IF | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    CURRENT_GW=$(echo $CURRENT_IP | cut -d. -f1-3).1
fi

echo ">>> Hệ thống hiện tại: Interface [$LAN_IF], Gateway dự kiến [$CURRENT_GW]"

# 2. Nhập IP mới
read -p "Nhập IP tĩnh mới bạn muốn đặt: " NEW_IP

# 3. Vô hiệu hóa Cloud-init Network (Chống bị ghi đè file Netplan)
echo ">>> Disable Cloud-init network config..."
mkdir -p /etc/cloud/cloud.cfg.d/
echo "network: {config: disabled}" > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

# 4. Cấu hình Netplan (IP tĩnh + Tắt IPv6)
# Tìm file netplan hiện có, nếu không có tạo file mới
NETPLAN_FILE=$(ls /etc/netplan/*.yaml | head -n1)
[ -z "$NETPLAN_FILE" ] && NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"

echo ">>> Ghi cấu hình vào $NETPLAN_FILE (Backup tại .bak)"
cp "$NETPLAN_FILE" "${NETPLAN_FILE}.bak"

cat <<EOF > "$NETPLAN_FILE"
network:
  version: 2
  renderer: networkd
  ethernets:
    $LAN_IF:
      dhcp4: no
      dhcp6: no
      accept-ra: false
      addresses:
        - $NEW_IP/24
      routes:
        - to: default
          via: $CURRENT_GW
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

# 5. Module Disable IPv6 triệt để (sysctl + GRUB)
echo ">>> Disable IPv6 triệt để..."

# Sysctl
cat <<EOF > /etc/sysctl.d/99-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.$LAN_IF.disable_ipv6 = 1
EOF
sysctl --system > /dev/null

# GRUB (Hard kill)
if ! grep -q "ipv6.disable=1" /etc/default/grub; then
    echo ">>> Cấu hình GRUB để tắt IPv6 hoàn toàn..."
    # Thêm ipv6.disable=1 vào dòng GRUB_CMDLINE_LINUX_DEFAULT
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1 /' /etc/default/grub
    update-grub > /dev/null
fi

# 6. Áp dụng ngay
echo ">>> Đang thực thi netplan apply..."
netplan apply

echo "--------------------------------------------------"
echo "THÀNH CÔNG!"
echo "Interface: $LAN_IF"
echo "IP mới:    $NEW_IP"
echo "Gateway:   $CURRENT_GW"
echo "IPv6:      Đã vô hiệu hóa (Cần reboot để GRUB có hiệu lực 100%)"
echo "--------------------------------------------------"
