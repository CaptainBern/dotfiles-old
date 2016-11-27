# Arch Installation Guide

(aka the notes I use to install Arch)

## Set the keyboard layout

```shell
loadkeys be-latin1
```

## Verify UEFI mode

```shell
ls /sys/firmware/efi/efivars
```

(if the `/sys/firmware/efi/efivars` directory does not exist, you are not running in UEFI mode)

## Connect to the internet

On a wifi-only system:
```shell
wifi-menu
```

## Configuring System Clock

```shell
timedatectl set-ntp true
```

## Preparing the disk

3 partitions are required:
   - 512MB EFI System Partition of type `EF00` is FAT32 formatted (for /boot/efi)
   - 512MB Boot Partition of type `8300` (for /boot)
   - Rest of the system of type `8E00` (lvm)

### Partitioning

1. Run `parted /dev/sdx`
2. Creating the ESP Partition:
    - Run `mktable gpt`
    - Run `unit MB`
    - Run `mkpart ESP fat32 0% 513`
    - Run `set 1 boot on`
3. Creating the Boot Partition:
    - Run `mkpart primary ext2 513 1026`
4. Creating the LVM Partition:
    - Run `mkpart primary ext4 1026 100%`
    - Run `set 3 lvm on`
5. Run `quit`

### Encryption

```shell
# Optionally cleanup the LVM partition (can do with every partition)
cryptsetup open --type plain /dev/sdx3 lvm --key-file /dev/random
dd if=/dev/zero of=/dev/mapper/lvm status=progress
cryptsetup close lvm

# Setup the encryption
cryptsetup -c aes-xts-plain64 -y --use-random luksFormat /dev/sdx3
cryptsetup open --type luks /dev/sdx3 lvm
```

Check if the partitions look good:
```shell
 gdisk /dev/sdx 
```

### Preparing the logical volumes

Create the volume group:
```shell
pvcreate /dev/mapper/lvm
vgcreate Arch /dev/mapper/lvm
lvcreate -L 4G Arch -n swap
lvcreate -L 20G Arch -n root
lvcreate -l +100%FREE Arch -n home
```

Format the filesystems:
```shell
mkfs.vfat -F32 /dev/sdx1
mkfs.ext4 /dev/mapper/Arch-root
mkfs.ext4 /dev/mapper/Arch-home
mkswap /dev/mapper/Arch-swap
```

Mount the filesystems:
```shell
mount /dev/mapper/Arch-root /mnt
mkdir /mnt/home
mount /dev/mapper/Arch-home /mnt/home
swapon /dev/mapper/Arch-swap
```

### Preparing the boot partition

```shell
cryptsetup -c aes-xts-plain64 -y --use-random luksFormat /dev/sdx2
cryptsetup open --type luks /dev/sdx2 cryptboot
mkfs.ext2 /dev/mapper/cryptboot
mkdir /mnt/boot
mount /dev/mapper/cryptboot /mnt/boot
mkdir /mnt/boot/efi
mount /dev/sdx1 /mnt/boot/efi
```

Check if the partitions make sense:
```shell
lsblk
```

## Arch Installation

### Install the base packages

```shell
pacstrap /mnt base base-devel
```

### Configure the system

```shell
# Create the fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Check if the file makes sense
cat /mnt/etc/fstab

# Change root
arch-chroot /mnt

# Setup the localtime
ln -s /usr/share/zoneinfo/Europe/Brussels /etc/localtime

# Generate /etc/adjtime
hwclock --systohc

# Uncomment 'en_GB.UTF-8 UTF-8' in /etc/locale.gen and run 'locale-gen'.
echo "LANG=en_GB.UTF-8" > /etc/locale.conf

# Set keyboard
echo "KEYMAP=be-latin1" > /etc/vconsole.conf

# Set hostname
# Optionally add '127.0.1.1	myhostname.localdomain	myhostname' to /etc/hosts
echo myhostname > /etc/hostname

# Install the required wifi packages (install firmware packages too)
pacman -S iw wpa_supplicant dialog 

# Change the root password
passwd
```

### Configure the bootloader

Install GRUB and efibootmgr:
```shell
pacman -S grub efibootmgr
```

Configure `mkinitcpio` in `/etc/mkinitcpio.conf`:
```shell
HOOKS="... keymap keyboard block encrypt lvm2 filesystems ..."
```
Then run `mkinitcpio -p linux`.

Create `/etc/default/grub`:
```shell
# `<device-UUID>` is the UUID of the partition holding the root filesystem. You can find it by running `blkid /dev/sdx3`
GRUB_CMDLINE_LINUX="cryptdevice=UUID=<device-UUID>:lvm"
GRUB_ENABLE_CRYPTODISK=y
```

Generate GRUB's default config and install to the mounted ESP:
```shell
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck
```

### Configure fstab and crypttab

Create a random-text keyfile:
```shell
dd bs=512 count=4 if=/dev/urandom of=/etc/cryptboot_keyfile iflag=fullblock
```

Add the keyfile to the boot-partition's LUKS header:
```shell
cryptsetup luksAddKey /dev/sdx2 /etc/cryptboot_keyfile
```

Edit /etc/fstab:
```shell
/dev/mapper/cryptboot       /boot   ext2        defaults        0       2
```

Edit /etc/crypttab:
```shell
cryptboot    /dev/sdx2    /etc/cryptboot_keyfile    luks
```

Making the keyfile a bit safer:
```shell
chmod 000 /etc/cryptboot_keyfile
chmod -R g-rwx,o-rwx /boot  
```

## Finishing the installation

```shell
exit
umount -R /mnt
reboot
```

##Setting up users

Add a new user:
```shell
useradd -m -G wheel -s /bin/bash USER_NAME
```

Install `sudo`:
```shell
pacman -S sudo
```

Edit `/etc/sudoers` and uncomment `# %wheel      ALL=(ALL) ALL`:
```shell
visudo
```

## Setup NetworkManager

```shell
pacaur -S networkmanager dhclient
```

Tell NetworkManager to use `dhclient` as its dhcp-client:
```shell
# Open /etc/NetworkManager/NetworkManager.conf
# Add 'dhcp=dhclient' under '[main]'. E.g.:

[main]
dns=default
dhcp=dhclient
```

Enable the NetworkManager service and start it:
```shell
systemctl enable NetworkManager.service
systemctl start NetworkManager.service
```
