#!/bin/bash

# Yêu cầu người dùng nhập IP LAN
read -p "Nhập IP LAN tĩnh cho server (ví dụ 192.168.1.5): " IP_ADDRESS

# Bước 1: Tạo thư mục cloud.cfg.d nếu chưa có
sudo mkdir -p /etc/cloud/cloud.cfg.d

# Bước 2: Kiểm tra file disable network config đã tồn tại chưa
DISABLE_FILE=$(ls /etc/cloud/cloud.cfg.d/ | grep -E ".*-disable-network-config.cfg" || true)

if [ -n "$DISABLE_FILE" ]; then
  echo "Đã tìm thấy file $DISABLE_FILE, sẽ ghi đè nội dung."
  echo "network: {config: disabled}" | sudo tee /etc/cloud/cloud.cfg.d/"$DISABLE_FILE" > /dev/null
else
  echo "Không tìm thấy file disable-network-config, tạo mới 99-disable-network-config.cfg."
  echo "network: {config: disabled}" | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg > /dev/null
fi

# Bước 3: Xác định file netplan cần chỉnh sửa
NETPLAN_FILE=$(ls /etc/netplan/ | grep -E ".*\.yaml" | head -n1)

if [ -z "$NETPLAN_FILE" ]; then
  echo "Không tìm thấy file netplan nào trong /etc/netplan/, thoát."
  exit 1
fi

echo "Đang chỉnh sửa file /etc/netplan/$NETPLAN_FILE..."

# Bước 4: Viết mới nội dung file netplan
sudo tee /etc/netplan/"$NETPLAN_FILE" > /dev/null <<EOF
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: false
      addresses:
        - ${IP_ADDRESS}/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
EOF

# Bước 5: Apply netplan
echo "Áp dụng cấu hình mạng mới..."
sudo netplan apply

echo "✅ Hoàn tất. IP mới: ${IP_ADDRESS}"
