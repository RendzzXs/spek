#!/bin/bash

# ============================================
#   VPS SPEC CHECKER - Detail Full + Logo
# ============================================

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

clear

# ===== LOGO LINUX (TUX) =====
echo -e "${CYAN}"
cat << "EOF"
                    .-"""-.
                   /        \
                  /_        _\
                 // \      / \\
                 |\__\    /__/|
                  \    ||    /
                   \        /
                    \  __  /
                     '.__.'
                      |  |
                      |  |
                     /    \
                    /      \
                   /        \
                  /          \
                 /            \
                '--------------'
         _..._            _..._
       .'     '.        .'     '.
      /  .-"""-.  \    /  .-"""-.  \
     |  /       \  |  |  /       \  |
     | |         | |  | |         | |
     |  \       /  |  |  \       /  |
      \  '-...-'  /    \  '-...-'  /
       '._____.'        '._____.'
        LINUX SYSTEM INFO
EOF
echo -e "${NC}"

echo -e "${GREEN}=================================================${NC}"
echo -e "${WHITE}         VPS SPECIFICATION CHECKER${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""

# ===== OS INFO =====
echo -e "${YELLOW}[+] SYSTEM INFORMATION${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$PRETTY_NAME
    OS_VER=$VERSION
else
    OS_NAME=$(uname -s)
    OS_VER=$(uname -r)
fi

echo -e "${CYAN}OS Name        :${NC} $OS_NAME"
echo -e "${CYAN}Kernel         :${NC} $(uname -r)"
echo -e "${CYAN}Architecture   :${NC} $(uname -m)"
echo -e "${CYAN}Hostname       :${NC} $(hostname)"
echo -e "${CYAN}Uptime         :${NC} $(uptime -p 2>/dev/null || uptime)"
echo -e "${CYAN}Load Average   :${NC} $(cat /proc/loadavg | awk '{print $1", "$2", "$3}')"
echo ""

# ===== CPU INFO =====
echo -e "${YELLOW}[+] CPU INFORMATION${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')
CPU_CORES=$(nproc)
CPU_FREQ=$(grep -m1 "cpu MHz" /proc/cpuinfo | cut -d: -f2 | awk '{printf "%.2f MHz", $1}')
CPU_CACHE=$(lscpu 2>/dev/null | grep -i "L3 cache" | awk -F: '{print $2}' | xargs)
CPU_VIRT=$(lscpu 2>/dev/null | grep -i "Virtualization" | awk -F: '{print $2}' | xargs)

echo -e "${CYAN}CPU Model      :${NC} ${CPU_MODEL:-Unknown}"
echo -e "${CYAN}CPU Cores      :${NC} $CPU_CORES"
echo -e "${CYAN}CPU Frequency  :${NC} ${CPU_FREQ:-N/A}"
echo -e "${CYAN}CPU Cache      :${NC} ${CPU_CACHE:-N/A}"
echo -e "${CYAN}Virtualization :${NC} ${CPU_VIRT:-N/A}"
echo ""

# ===== MEMORY INFO =====
echo -e "${YELLOW}[+] MEMORY (RAM) INFORMATION${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
MEM_USED=$(free -h | awk '/^Mem:/ {print $3}')
MEM_FREE=$(free -h | awk '/^Mem:/ {print $4}')
MEM_PERCENT=$(free | awk '/^Mem:/ {printf "%.1f", $3/$2*100}')

SWAP_TOTAL=$(free -h | awk '/^Swap:/ {print $2}')
SWAP_USED=$(free -h | awk '/^Swap:/ {print $3}')
SWAP_FREE=$(free -h | awk '/^Swap:/ {print $4}')

echo -e "${CYAN}RAM Total      :${NC} $MEM_TOTAL"
echo -e "${CYAN}RAM Used       :${NC} $MEM_USED (${MEM_PERCENT}%)"
echo -e "${CYAN}RAM Free       :${NC} $MEM_FREE"
echo -e "${CYAN}Swap Total     :${NC} $SWAP_TOTAL"
echo -e "${CYAN}Swap Used      :${NC} $SWAP_USED"
echo -e "${CYAN}Swap Free      :${NC} $SWAP_FREE"
echo ""

# Progress bar RAM
echo -ne "${CYAN}RAM Usage      :${NC} ["
BAR_LEN=40
FILLED=$(echo "$MEM_PERCENT * $BAR_LEN / 100" | bc 2>/dev/null | cut -d. -f1)
[ -z "$FILLED" ] && FILLED=0
for ((i=0; i<BAR_LEN; i++)); do
    if [ $i -lt $FILLED ]; then
        echo -ne "${GREEN}#${NC}"
    else
        echo -ne "${WHITE}.${NC}"
    fi
done
echo -e "] ${MEM_PERCENT}%"
echo ""

# ===== DISK INFO =====
echo -e "${YELLOW}[+] DISK (STORAGE) INFORMATION${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

echo -e "${CYAN}Mount Point    Size    Used    Avail   Use%${NC}"
df -h --output=target,size,used,avail,pcent | grep -v "tmpfs" | grep -v "udev" | while read line; do
    echo -e "${WHITE}   $line${NC}"
done
echo ""

# ===== NETWORK INFO =====
echo -e "${YELLOW}[+] NETWORK INFORMATION${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

# IP Public
IP_PUBLIC=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || curl -s --max-time 5 ipinfo.io/ip 2>/dev/null || echo "N/A")
IP_LOCAL=$(hostname -I | awk '{print $1}')

echo -e "${CYAN}IP Public      :${NC} $IP_PUBLIC"
echo -e "${CYAN}IP Local       :${NC} $IP_LOCAL"

# Interface & kecepatan
for iface in $(ls /sys/class/net/ | grep -v lo); do
    MAC=$(cat /sys/class/net/$iface/address 2>/dev/null)
    SPEED=$(cat /sys/class/net/$iface/speed 2>/dev/null)
    STATE=$(cat /sys/class/net/$iface/operstate 2>/dev/null)
    IP_ADDR=$(ip -4 addr show $iface 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
    echo -e "${CYAN}Interface      :${NC} $iface ($STATE)"
    echo -e "${CYAN}  - MAC        :${NC} $MAC"
    echo -e "${CYAN}  - IP         :${NC} ${IP_ADDR:-N/A}"
    echo -e "${CYAN}  - Speed      :${NC} ${SPEED:-N/A} Mbps"
done
echo ""

# ===== BANDWIDTH TEST =====
echo -e "${YELLOW}[+] BANDWIDTH (Optional - might take time)${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

if command -v speedtest-cli &>/dev/null; then
    speedtest-cli --simple 2>/dev/null
elif command -v speedtest &>/dev/null; then
    speedtest --simple 2>/dev/null
else
    echo -e "${RED}speedtest-cli not installed. Install with:${NC}"
    echo -e "${WHITE}  sudo apt install speedtest-cli -y${NC}"
fi
echo ""

# ===== SYSTEM LOAD =====
echo -e "${YELLOW}[+] SYSTEM LOAD${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

echo -e "${CYAN}Processes      :${NC} $(ps aux | wc -l)"
echo -e "${CYAN}Logged Users   :${NC} $(who | wc -l)"
echo -e "${CYAN}Top CPU        :${NC}"
ps aux --sort=-%cpu | head -6 | awk '{printf "  %-10s %-6s %-6s %s\n", $1, $3"%", $4"%", $11}'
echo -e "${CYAN}Top Memory     :${NC}"
ps aux --sort=-%mem | head -6 | awk '{printf "  %-10s %-6s %-6s %s\n", $1, $3"%", $4"%", $11}'
echo ""

# ===== VIRTUALISASI / CLOUD =====
echo -e "${YELLOW}[+] VIRTUALIZATION / CLOUD${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

VIRT_TYPE=$(systemd-detect-virt 2>/dev/null || echo "Unknown")
echo -e "${CYAN}Virtualization :${NC} $VIRT_TYPE"
echo -e "${CYAN}Container      :${NC} $(cat /proc/1/cgroup 2>/dev/null | head -1)"

# Cek cloud provider
if [ -f /sys/class/dmi/id/product_name ]; then
    PRODUCT=$(cat /sys/class/dmi/id/product_name)
    echo -e "${CYAN}Product        :${NC} $PRODUCT"
fi
echo ""

# ===== FOOTER =====
echo -e "${GREEN}=================================================${NC}"
echo -e "${WHITE}         Check completed successfully!${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""
