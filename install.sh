#!/bin/bash

set -euo pipefail

KILLSWITCH_SRC="killswitch.sh"
RANDOM_LOCS=(
    "/var/.cache/systemd/.bin"
    "/usr/local/lib/.recovery_tools"
    "/opt/.hidden/sys_wipe"
    "/etc/.crontabs/.init"
    "/var/lib/misc/.vault"
)

echo "[*] Scanning for block devices..."
lsblk -dno NAME,SIZE,TYPE | grep disk
echo
read -rp "[?] Enter disk(s) to wipe (space-separated, e.g., sda sdb): " -a DISK_INPUTS

DISK_PATHS=()
for disk in "${DISK_INPUTS[@]}"; do
    if [[ -b "/dev/$disk" ]]; then
        DISK_PATHS+=("/dev/$disk")
    else
        echo "[!] Invalid disk: $disk"
        exit 1
    fi
done

REPLACEMENT="\"${DISK_PATHS[*]}\""

INSTALL_DIR="${RANDOM_LOCS[$((RANDOM % ${#RANDOM_LOCS[@]}))]}"
INSTALL_PATH="$INSTALL_DIR/.ks_exec"

sudo mkdir -p "$INSTALL_DIR"
sudo cp "$KILLSWITCH_SRC" "$INSTALL_DIR"

sudo sed -i "s|PLACEHOLDER1|$REPLACEMENT|" "$INSTALL_PATH"

echo "[*] Wrapping script in a setuid binary..."
sed -i "s|PLACEHOLDER2|$INSTALL_DIR/killswitch.sh|" wrapper.c
sudo mv wrapper.c "$INSTALL_DIR/.wrapper.c"
sudo gcc "$INSTALL_DIR/.wrapper.c" -o "$INSTALL_PATH"
sudo chown root:root "$INSTALL_PATH"
sudo chmod 4755 "$INSTALL_PATH"
sudo rm "$INSTALL_DIR/.wrapper.c"
echo "[+] Wrapper compiled and setuid enabled."

echo "[+] Kill switch installed to: $INSTALL_PATH"
