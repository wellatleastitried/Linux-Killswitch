#!/bin/bash

LOG="/dev/shm/killswitch.log"
log() { echo "[$(date +%T)] $1" >> "$LOG"; }

if [[ "$0" != "/dev/shm/.ks_exec" ]]; then
    cp "$0" /dev/shm/.ks_exec && exec /bin/bash /dev/shm/.ks_exec "$0"
fi

[[ -n "${1:-}" ]] && shred -n 1 -z -u "$1" 2>/dev/null || true

set -euo pipefail

DISKS=(PLACEHOLDER1)
SHRED_DIRS=("/home" "/tmp" "/var/tmp" "/root")
FILL_MOUNTS=("/" "/home")

disable_network_interfaces() {
    log "[*] Disabling all network interfaces..."
    for iface in $(ls /sys/class/net | grep -v lo); do
        ip link set "$iface" down || true
    done
}

shred_dir() {
    dir="$1"
    log "[*] Shredding contents of $dir ..."
    find "$dir" -type f -exec shred -n 1 -z -u {} + 2>/dev/null || true
}

shred_all_dirs() {
    for d in "${SHRED_DIRS[@]}"; do
        shred_dir "$d" &
    done
    wait
    log "[+] File-level shredding done."
}

shred_swaps() {
    log "[*] Disabling and shredding swap..."
    swaps=$(awk '/swap/ {print $1}' /proc/swaps)
    for s in $swaps; do
        swapoff "$s" || true
        shred -n 1 -z "$s" || true
    done
    log "[+] Swap wiped."
}

zero_fill_mount() {
    mnt="$1"
    log "[*] Zero-filling free space on $mnt ..."
    dd if=/dev/zero of="$mnt/zero.fill" bs=1M status=none 2>/dev/null || true
    rm -f "$mnt/zero.fill"
}

fill_all_mounts() {
    for mnt in "${FILL_MOUNTS[@]}"; do
        zero_fill_mount "$mnt" &
    done
    wait
    log "[+] Slack space wiped."
}

nuke_raw_block_devices() {
    log "[*] Nuking raw block devices..."
    for disk in "${DISKS[@]}"; do
        log "[*] Wiping $disk ..."
        blkdiscard "$disk" 2>/dev/null || shred -n 1 -z "$disk"
    done
    log "[+] Device-level destruction done."
}

wipe_signatures() {
    log "[*] Wiping filesystem signatures..."
    for disk in "${DISKS[@]}"; do
        wipefs -a "$disk" || log "[!] wipefs failed on $disk"
    done
    log "[+] Filesystem signatures wiped."
}

wipe_bootloader() {
    log "[*] Wiping bootloader sectors..."
    for disk in "${DISKS[@]}"; do
        dd if=/dev/zero of="$disk" bs=512 count=1 status=none || true
    done
    log "[+] Bootloader wiped."
}

drop_flush_memory() {
    log "[*] Dropping caches and flushing memory..."
    command -v sync >/dev/null || log "[!] sync failed or missing"
    echo 3 > /proc/sys/vm/drop_caches || log "[!] Failed to drop caches"
}

grand_finale() {
    log "[!] Kill switch complete. Attempting to power off..."
    set +e
    sync
    echo o > /proc/sysrq-trigger
}

log "[*] Starting kill switch at $(date)"
disable_network_interfaces
corrupt_framebuffer
drop_flush_memory
shred_all_dirs
shred_swaps
fill_all_mounts
nuke_raw_block_devices
wipe_signatures
wipe_bootloader
grand_finale
