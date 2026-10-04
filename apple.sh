#!/bin/bash

# ============================================
#   DEVICE SPEC CHECKER - Apple Style + Logo
# ============================================

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

clear

# ===== LOGO APPLE =====
echo -e "${WHITE}"
cat << "EOF"
                    'c.
                 ,xNMM.
               .OMMMMo
               OMMM0,
     .;loddo:' loolloddol;.
   cKMMMMMMMMMMNWMMMMMMMMMM0:
 .KMMMMMMMMMMMMMMMMMMMMMMMWd.
 XMMMMMMMMMMMMMMMMMMMMMMMX.
;MMMMMMMMMMMMMMMMMMMMMMMM:
:MMMMMMMMMMMMMMMMMMMMMMMM:
.MMMMMMMMMMMMMMMMMMMMMMMMX.
 kMMMMMMMMMMMMMMMMMMMMMMMMWd.
 .XMMMMMMMMMMMMMMMMMMMMMMMMMMk
  .XMMMMMMMMMMMMMMMMMMMMMMMMK.
    kMMMMMMMMMMMMMMMMMMMMMMd
     ;KMMMMMMMWXXWMMMMMMMk.
       .cooc,.    .,coo:.

        macOS / iOS SYSTEM
EOF
echo -e "${NC}"

echo -e "${GREEN}=================================================${NC}"
echo -e "${WHITE}       DEVICE SPECIFICATION CHECKER${NC}"
echo -e "${WHITE}            Apple Edition 🍎${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""

# ===== SYSTEM INFO =====
echo -e "${YELLOW}[+] SYSTEM INFORMATION${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

OS_NAME=$(sw_vers -productName 2>/dev/null || uname -s)
OS_VER=$(sw_vers -productVersion 2>/dev/null || uname -r)
OS_BUILD=$(sw_vers -buildVersion 2>/dev/null || echo "N/A")
KERNEL=$(uname -r)
ARCH=$(uname -m)
HOSTNAME=$(hostname)
UPTIME=$(uptime | sed 's/.*up //' | sed 's/,.*//')

echo -e "${CYAN}OS Name        :${NC} $OS_NAME"
echo -e "${CYAN}OS Version     :${NC} $OS_VER ($OS_BUILD)"
echo -e "${CYAN}Kernel         :${NC} $KERNEL"
echo -e "${CYAN}Architecture   :${NC} $ARCH"
echo -e "${CYAN}Hostname       :${NC} $HOSTNAME"
echo -e "${CYAN}Uptime         :${NC} $UPTIME"
echo ""

# ===== HARDWARE / DEVICE =====
echo -e "${YELLOW}[+] HARDWARE INFORMATION${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

if command -v system_profiler &>/dev/null; then
    # macOS
    MODEL=$(sysctl -n hw.model 2>/dev/null)
    CHIP=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || sysctl -n hw.model)
    CORES=$(sysctl -n hw.ncpu 2>/dev/null)
    MEM=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.2f GB", $1/1024/1024/1024}')
    SERIAL=$(system_profiler SPHardwareDataType 2>/dev/null | grep "Serial" | awk -F: '{print $2}' | xargs)

    echo -e "${CYAN}Model          :${NC} $MODEL"
    echo -e "${CYAN}Chip/CPU       :${NC} $CHIP"
    echo -e "${CYAN}CPU Cores      :${NC} $CORES"
    echo -e "${CYAN}Memory (RAM)   :${NC} $MEM"
    echo -e "${CYAN}Serial Number  :${NC} $SERIAL"
else
    # Linux (iSH / Termux / VPS)
    CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ //')
    [ -z "$CPU_MODEL" ] && CPU_MODEL=$(grep -m1 "Hardware" /proc/cpuinfo | cut -d: -f2)
    CPU_CORES=$(nproc 2>/dev/null)
    MEM=$(free -h 2>/dev/null | awk '/^Mem:/ {print $2}')
    DEVICE=$(cat /sys/firmware/devicetree/base/model 2>/dev/null || cat /proc/device-tree/model 2>/dev/null || echo "Unknown")

    echo -e "${CYAN}Device         :${NC} $DEVICE"
    echo -e "${CYAN}Chip/CPU       :${NC} ${CPU_MODEL:-Unknown}"
    echo -e "${CYAN}CPU Cores      :${NC} $CPU_CORES"
    echo -e "${CYAN}Memory (RAM)   :${NC} ${MEM:-N/A}"
fi
echo ""

# ===== MEMORY =====
echo -e "${YELLOW}[+] MEMORY INFORMATION${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

if command -v vm_stat &>/dev/null; then
    # macOS
    PAGESIZE=$(pagesize)
    VMSTAT=$(vm_stat)
    PAGES_FREE=$(echo "$VMSTAT" | awk '/Pages free/ {gsub(/\./,"",$3); print $3}')
    PAGES_ACTIVE=$(echo "$VMSTAT" | awk '/Pages active/ {gsub(/\./,"",$3); print $3}')
    PAGES_INACTIVE=$(echo "$VMSTAT" | awk '/Pages inactive/ {gsub(/\./,"",$3); print $3}')
    PAGES_WIRED=$(echo "$VMSTAT" | awk '/Pages wired/ {gsub(/\./,"",$4); print $4}')

    FREE_MB=$((PAGES_FREE * PAGESIZE / 1024 / 1024))
    ACTIVE_MB=$((PAGES_ACTIVE * PAGESIZE / 1024 / 1024))
    WIRED_MB=$((PAGES_WIRED * PAGESIZE / 1024 / 1024))
    TOTAL_MB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 ))
    USED_MB=$((TOTAL_MB - FREE_MB))
    PERCENT=$((USED_MB * 100 / TOTAL_MB))

    echo -e "${CYAN}Total RAM      :${NC} ${TOTAL_MB} MB"
    echo -e "${CYAN}Used RAM       :${NC} ${USED_MB} MB (${PERCENT}%)"
    echo -e "${CYAN}Free RAM       :${NC} ${FREE_MB} MB"
    echo -e "${CYAN}Wired          :${NC} ${WIRED_MB} MB"
else
    # Linux
    MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
    MEM_USED=$(free -h | awk '/^Mem:/ {print $3}')
    MEM_FREE=$(free -h | awk '/^Mem:/ {print $4}')
    PERCENT=$(free | awk '/^Mem:/ {printf "%.1f", $3/$2*100}')

    echo -e "${CYAN}Total RAM      :${NC} $MEM_TOTAL"
    echo -e "${CYAN}Used RAM       :${NC} $MEM_USED (${PERCENT}%)"
    echo -e "${CYAN}Free RAM       :${NC} $MEM_FREE"
fi

# Progress bar
echo -ne "${CYAN}RAM Usage      :${NC} ["
FILLED=$(echo "${PERCENT:-0} * 40 / 100" | bc 2>/dev/null | cut -d. -f1)
[ -z "$FILLED" ] && FILLED=0
for ((i=0; i<40; i++)); do
    if [ $i -lt $FILLED ]; then
        echo -ne "${GREEN}#${NC}"
    else
        echo -ne "${GRAY}.${NC}"
    fi
done
echo -e "] ${PERCENT}%"
echo ""

# ===== STORAGE =====
echo -e "${YELLOW}[+] STORAGE INFORMATION${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

df -h | grep -v "map" | grep -v "devfs" | while read line; do
    echo -e "${WHITE}  $line${NC}"
done
echo ""

# ===== BATTERY (khusus laptop/iPhone) =====
echo -e "${YELLOW}[+] BATTERY INFORMATION${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

if command -v pmset &>/dev/null; then
    pmset -g batt | tail -1-time
elif [ -f  /sys/class/power_supply/BAT0/capacity ]; then
    BAT=$(cat /sys/class/power_supply/BAT0/capacity)
    STATUS=$(cat /sys/class/power_supply/BAT0/status)
    echo -e "${CYAN}Battery Level  :${NC} ${BAT}%"
    echo -e "${CYAN}Status         :${NC} $STATUS"
else
    echo -e "${RED}No battery info available${NC}"
fi
echo ""

# ===== NETWORK =====
echo -e "${YELLOW}[+] NETWORK INFORMATION${NC}"
echo -e "${GREEN}-------------------------------------------------${NC}"

IP_PUBLIC=$(curl -s --max5 ifconfig.me 2>/dev/null || echo "N/A")
IP_LOCAL=$(hostname -I 2>/dev/null | awk '{print $1}' || ipconfig getifaddr en0 2>/dev/null || echo "N/A")

echo -e "${CYAN}IP Public      :${NC} $IP_PUBLIC"
echo -e "${CYAN}IP Local       :${NC} $IP_LOCAL"

if command -v ifconfig &>/dev/null; then
    for iface in $(ifconfig -l 2>/dev/null | tr ' ' '\n' | grep -v lo); do
        IP=$(ipconfig getifaddr $iface 2>/dev/null)
        [ -n "$IP" ] && echo -e "${CYAN}  - $iface        :${NC} $mod +IP"
    done
fi
echo ""

# ===== KESIMPULAN =====
echo -e "${GREEN}=================================================${NC}"
echo -e "${WHITE}        ✅ Check completed successfully!${NC}"
echo -e "${WHITE}            🍎 Powered by Apple Style${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""
