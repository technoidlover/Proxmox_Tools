#!/bin/bash
set -e

LOGFILE="$HOME/server_setup_log.txt"
STATEFILE="$HOME/server_setup_state.txt"
exec > >(tee -a "$LOGFILE") 2>&1

# ==============================
# Danh sách module
# ==============================
modules=(
  "update_system"
  "install_qemu"
  "install_neofetch"
  "check_ip"

  "disable_ipv6"
  "basic_utils"
  "install_node"
  "install_bun"
  "install_php"
  "install_python"
  "install_mysql"
  "install_postgres"
  "install_mongodb"
  "install_dotnet"
  "create_env"
)

# ==============================
# Các hàm cài module
# ==============================
update_system() {
  echo ">>> Cập nhật hệ thống..."
  sudo apt update -y && sudo apt upgrade -y
}

install_qemu() {
  echo ">>> Cài đặt QEMU Guest Agent..."
  sudo apt install -y qemu-guest-agent
  sudo systemctl enable --now qemu-guest-agent
}

install_neofetch() {
  echo ">>> Cài đặt Neofetch..."
  sudo apt install -y neofetch
}

check_ip() {
  echo ">>> Kiểm tra IP LAN..."
  LAN_IF=$(ip route | grep '^default' | awk '{print $5}')
  IP_ADDR=$(ip -4 addr show "$LAN_IF" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
  echo "Interface: $LAN_IF"
  echo "Current IP: $IP_ADDR"
}


disable_ipv6() {
  echo ">>> Disable IPv6..."
  sudo tee /etc/sysctl.d/99-disable-ipv6.conf > /dev/null <<EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
  sudo sysctl --system
}

basic_utils() {
  echo ">>> Cài đặt tiện ích cơ bản..."
  sudo apt install -y htop curl wget git unzip zip tmux build-essential software-properties-common apt-transport-https lsb-release ca-certificates gnupg
}

install_node() {
  echo ">>> Cài đặt Node.js (NVM)..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
}

install_bun() {
  echo ">>> Cài đặt Bun.js..."
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
}

install_php() {
  echo ">>> Cài đặt PHP + Composer..."
  sudo apt install -y php-cli php-mbstring php-xml php-curl unzip
  EXPECTED_SIG=$(wget -q -O - https://composer.github.io/installer.sig)
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  ACTUAL_SIG=$(php -r "echo hash_file('sha384', 'composer-setup.php');")
  if [ "$EXPECTED_SIG" = "$ACTUAL_SIG" ]; then
      php composer-setup.php --install-dir=/usr/local/bin --filename=composer
  fi
  rm composer-setup.php
}

install_python() {
  echo ">>> Cài đặt Python..."
  sudo apt install -y python3 python3-pip python3-venv
}

install_mysql() {
  echo ">>> Cài đặt MySQL..."
  sudo apt install -y mysql-server
  sudo systemctl enable --now mysql
  sudo sed -i 's/^port\s*=.*/port = 3307/' /etc/mysql/mysql.conf.d/mysqld.cnf
  sudo systemctl restart mysql
}

install_postgres() {
  echo ">>> Cài đặt PostgreSQL..."
  sudo apt install -y postgresql postgresql-contrib
  sudo systemctl enable --now postgresql
  sudo sed -i "s/#port = 5432/port = 5433/" /etc/postgresql/*/main/postgresql.conf
  sudo systemctl restart postgresql
}

install_mongodb() {
  echo ">>> Cài đặt MongoDB..."
  wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
  sudo apt update -y
  sudo apt install -y mongodb-org
  sudo systemctl enable --now mongod
}

install_dotnet() {
  echo ">>> Cài đặt .NET SDK..."
  wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb
  sudo apt update -y
  sudo apt install -y dotnet-sdk-7.0
}

create_env() {
  echo ">>> Tạo file .env mặc định cho databases..."
  ENV_FILE="$HOME/server_env.env"
  cat > "$ENV_FILE" <<EOL
# MySQL
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3307
MYSQL_DATABASE=mydb
MYSQL_USER=admin
MYSQL_PASSWORD=Admin123!

# PostgreSQL
PG_HOST=127.0.0.1
PG_PORT=5433
PG_DATABASE=pgdb
PG_USER=pgadmin
PG_PASSWORD=PgAdmin123!

# MongoDB
MONGO_HOST=127.0.0.1
MONGO_PORT=27017
MONGO_DATABASE=mongodb
MONGO_USER=mongoadmin
MONGO_PASSWORD=Mongo123!
EOL
  echo "File .env tạo tại: $ENV_FILE"
}

# ==============================
# Hàm chạy module
# ==============================
run_module() {
  local module=$1
  echo "=== Bắt đầu module: $module ==="
  if $module; then
    echo "$module" >> "$STATEFILE"
    echo "=== Hoàn thành module: $module ==="
  else
    echo "!!! Lỗi module: $module, tiếp tục module khác..."
    echo "ERROR in $module" >> "$LOGFILE"
  fi
}

# ==============================
# Menu chính
# ==============================
main_menu() {
  echo "Chọn chế độ:"
  echo "1) Cài mới từ đầu"
  echo "2) Tiếp tục từ state trước"
  echo "3) Chọn module để cài"
  echo "4) Cài tất cả module (bỏ qua lỗi)"
  read -p "Lựa chọn: " choice

  case $choice in
    1)
      rm -f "$STATEFILE"
      for m in "${modules[@]}"; do
        run_module $m
        read -p "Tiếp tục (Enter), Tạm dừng (p), Bỏ qua (s): " act
        [[ "$act" == "p" ]] && exit 0
        [[ "$act" == "s" ]] && continue
      done
      ;;
    2)
      done_modules=($(cat "$STATEFILE" 2>/dev/null))
      for m in "${modules[@]}"; do
        if [[ ! " ${done_modules[@]} " =~ " ${m} " ]]; then
          run_module $m
          read -p "Tiếp tục (Enter), Tạm dừng (p), Bỏ qua (s): " act
          [[ "$act" == "p" ]] && exit 0
          [[ "$act" == "s" ]] && continue
        fi
      done
      ;;
    3)
      echo "Danh sách module:"
      for i in "${!modules[@]}"; do
        echo "$i) ${modules[$i]}"
      done
      read -p "Chọn số module: " idx
      run_module "${modules[$idx]}"
      ;;
    4)
      rm -f "$STATEFILE"
      for m in "${modules[@]}"; do
        run_module $m || true
      done
      ;;
    *)
      echo "Lựa chọn không hợp lệ"
      ;;
  esac
}

main_menu