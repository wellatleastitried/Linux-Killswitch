# Killswitch

This script is built to render the filesystem unusable and unrecoverable. The key steps used to do this are as follow:
- Disable persistence
- Turn off swap partition
- Shred files on mounted filesystem
- Wipe unallocated space
- Wipe journal/logs
- Shred temporary directories and shared memory
- Clear RAM cache
- Overwrite block devices
- Destroy bootloader/partition table
- Wipe filesystem signatures
- Overwrite critical system binaries
- Disable networking
- Self-destruct `killswitch.sh`
- Force reboot

## Installation
```bash
git clone "https://github.com/wellatleastitried/Linux-Killswitch.git"
cd Linux-Killswitch
./install.sh
```
Now copy the path displayed at the end of the install and set a keybind that WILL NOT BE ACCIDENTALLY PRESSED.

## Notice
I am not liable for any damage done to your computer. Use this script at your own risk and don't be stupid
