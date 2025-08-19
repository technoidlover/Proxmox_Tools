#!/bin/bash

# Function để validate IP address
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -ra ADDR <<< "$ip"
        for i in "${ADDR[@]}"; do
            if [[ $i -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

echo "🔍 Đang tự động phát hiện cấu hình mạng hiện tại..."

# Tự động phát hiện interface mạng chính
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
if [ -z "$INTERFACE" ]; then
    echo "❌ Không thể tự động phát hiện interface mạng."
    exit 1
fi
echo "📡 Interface được phát hiện: $INTERFACE"

# Tự động lấy IP hiện tại
CURRENT_IP=$(ip addr show "$INTERFACE" | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d'/' -f1 | head -n1)
if [ -z "$CURRENT_IP" ]; then
    echo "❌ Không thể phát hiện IP hiện tại trên interface $INTERFACE."
    exit 1
fi
echo "🌐 IP hiện tại được phát hiện: $CURRENT_IP"

# Tự động lấy Gateway hiện tại
CURRENT_GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n1)
if [ -z "$CURRENT_GATEWAY" ]; then
    echo "❌ Không thể phát hiện Gateway hiện tại."
    exit 1
fi
echo "🚪 Gateway hiện tại được phát hiện: $CURRENT_GATEWAY"

# Tự động phát hiện subnet mask (thường là /24 cho mạng LAN)
SUBNET_MASK=$(ip addr show "$INTERFACE" | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d'/' -f2 | head -n1)
if [ -z "$SUBNET_MASK" ]; then
    SUBNET_MASK="24"
    echo "⚠️  Không phát hiện được subnet mask, sử dụng mặc định /24"
else
    echo "🔢 Subnet mask được phát hiện: /$SUBNET_MASK"
fi

# Hiển thị thông tin sẽ được cấu hình
echo ""
echo "📋 Thông tin sẽ được cấu hình thành IP tĩnh:"
echo "   Interface: $INTERFACE"
echo "   IP Address: $CURRENT_IP/$SUBNET_MASK"
echo "   Gateway: $CURRENT_GATEWAY"
echo ""

# Hỏi xác nhận từ người dùng
read -p "Bạn có muốn tiếp tục cấu hình IP tĩnh với thông tin trên? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "❌ Hủy bỏ cấu hình."
    exit 0
fi

# Gán các biến để sử dụng trong phần còn lại của script
IP_ADDRESS="$CURRENT_IP"
GATEWAY="$CURRENT_GATEWAY"

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
  echo "❌ Không tìm thấy file netplan nào trong /etc/netplan/, thoát."
  exit 1
fi

echo "📄 Đang chỉnh sửa file /etc/netplan/$NETPLAN_FILE..."

# Bước 5: Backup file netplan gốc
echo "💾 Tạo backup file gốc..."
sudo cp /etc/netplan/"$NETPLAN_FILE" /etc/netplan/"$NETPLAN_FILE".backup.$(date +%Y%m%d_%H%M%S)

# Bước 6: Viết mới nội dung file netplan
sudo tee /etc/netplan/"$NETPLAN_FILE" > /dev/null <<EOF
network:
  version: 2
  ethernets:
    $INTERFACE:
      dhcp4: false
      addresses:
        - ${IP_ADDRESS}/${SUBNET_MASK}
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
EOF

# Bước 7: Test cấu hình netplan trước khi apply
echo "🔍 Kiểm tra cấu hình netplan..."
if sudo netplan generate; then
    echo "✅ Cấu hình netplan hợp lệ."
else
    echo "❌ Cấu hình netplan không hợp lệ. Khôi phục file backup..."
    sudo cp /etc/netplan/"$NETPLAN_FILE".backup.* /etc/netplan/"$NETPLAN_FILE"
    exit 1
fi

# Bước 8: Apply netplan
echo "🔄 Áp dụng cấu hình mạng mới..."
if sudo netplan apply; then
    echo "✅ Hoàn tất cấu hình IP tĩnh!"
    echo "📋 Thông tin cấu hình:"
    echo "   - IP Address: ${IP_ADDRESS}/${SUBNET_MASK}"
    echo "   - Gateway: ${GATEWAY}"
    echo "   - Interface: ${INTERFACE}"
    echo "   - DNS: 8.8.8.8, 8.8.4.4"
    echo "📄 File backup: /etc/netplan/$NETPLAN_FILE.backup.*"
    
    # Hiển thị thông tin mạng hiện tại
    echo ""
    echo "📊 Xác nhận cấu hình mạng hiện tại:"
    ip addr show "$INTERFACE" | grep "inet "
    echo ""
    echo "🌐 Test kết nối mạng:"
    if ping -c 2 8.8.8.8 >/dev/null 2>&1; then
        echo "✅ Kết nối internet thành công!"
    else
        echo "⚠️  Không thể kết nối internet. Vui lòng kiểm tra cấu hình."
    fi
else
    echo "❌ Lỗi khi áp dụng cấu hình. Khôi phục file backup..."
    sudo cp /etc/netplan/"$NETPLAN_FILE".backup.* /etc/netplan/"$NETPLAN_FILE"
    sudo netplan apply
    exit 1
fi
