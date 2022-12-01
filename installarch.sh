#!/bin/bash

# get parameters

DISK=$1
HOSTNAME=$2
USERNAME=$3
ROOTPASSWORD = $4
USERPASSWORD = $5

echo "Validating disk $DISK"

# check if the disk is a block device
if [ ! -b $DISK ]; then
  echo "Error: $DISK is not a block device"
  exit 1
fi

echo "Beginning installation of Arch Linux for $HOSTNAME on $DISK"

# now, we need to format the partitions

mkfs.fat -F32 ${DISK}1 # efi partition (fat32)
mkfs.ext4 ${DISK}2 # rootfs partition (ext4)

# mount partitions

mount ${DISK}1 /mnt/boot/efi
mount ${DISK}2 /mnt

# pacstrap

pacstrap /mnt base base-devel linux linux-firmware linux-headers man-db man-pages bash-completion

# fstab

genfstab -U /mnt >> /mnt/etc/fstab

# get the host timezone

TIMEZONE=$(readlink -f /etc/localtime)

# chroot in

arch-chroot /mnt <<EOF
# set the timezone
ln -sf $TIMEZONE /etc/localtime
hwclock --systohc

# set the hostname
echo $HOSTNAME > /etc/hostname

# hostfile
echo "
# IPv4
127.0.0.1	localhost
127.0.1.1	<your hostname>.localdomain <your hostname>

# IPv6
::1		localhost" > /etc/hosts

clear && echo "Please enter your root password (it will not be displayed), then press enter."

# set root password
passwd

# make a new user and set its password
useradd -m $USERNAME

clear && echo "Please enter your user password (it will not be displayed), then press enter."

passwd $USERNAME

usermod -aG wheel,audio,video,optical,storage $USERNAME

# uncomment wheel group in sudoers
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

pacman -S refind efibootmgr os-prober freetype2 dosfstools --noconfirm > /dev/null
refind-install

# install network tools
pacman -S dhcpcd net-tools netctl dialog wpa_supplicant networkmanager nm-connection-editor inetutils ifplugd --noconfirm

# enable services
systemctl enable {dhcpcd,NetworkManager,ifplugd}

exit
EOF


# unmount partitions
umount -R /mnt

echo "Installation complete. You may now reboot."
