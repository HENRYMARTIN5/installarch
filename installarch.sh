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

  # set root password
  passwd <<EOT
  $ROOTPASSWORD
  EOT

  # make a new user and set its password
  useradd -m $USERNAME

  passwd $USERNAME <<EOT
  $USERPASSWORD
  EOT

  usermod -aG wheel,audio,video,optical,storage $USERNAME

  # uncomment wheel group in sudoers
  sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

  pacman -S grub efibootmgr os-prober freetype2 dosfstools --noconfirm
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
  grub-mkconfig -o /boot/grub/grub.cfg

  # install network tools
  pacman -S dhcpcd net-tools netctl dialog wpa_supplicant networkmanager nm-connection-editor inetutils ifplugd --noconfirm

  exit
EOF

# enable services
systemctl enable {dhcpcd,NetworkManager,ifplugd}

# unmount partitions
umount -R /mnt

echo "Installation complete. You may now reboot."
