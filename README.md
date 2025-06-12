# Killswitch

This script is built to render the filesystem unusable and unrecoverable. The key steps used to do this are as follow:
- Disable network interfaces
- Shred files on mounted filesystem
- Disables and overwrites swap partitions
- Zero-fills remaining free space on mounted filesystems
- Overwrites entire raw block devices (`/dev/sdX`, etc)
- Destroys the first 512 bytes on the disk (which contains the bootloader/partition table)
- Drops page caches and flushes memory
- Executes entirely from memory to avoid leaving traces on disk
- Force-powers off the machine via `/proc/sysrq-trigger`

## Installation
```bash
git clone "https://github.com/wellatleastitried/Linux-Killswitch.git"
cd Linux-Killswitch
./install.sh
```
Now copy the path displayed at the end of the install and set a keybind that WILL NOT BE ACCIDENTALLY PRESSED.

## Warning
This script will destroy **everything** on the system, including:
- Your files
- Your operating system
- Your bootloader
- Your partition table
</br>
It *does not* ask for confirmation. It is your responsibility to use this safely. Misuse *WILL* lead to permanent data loss.
**I am not liable for any damage caused.**
