#!/bin/bash

# get parameters

DISK=$1
HOSTNAME=$2
USERNAME=$3
ROOTPASSWORD = $4
USERPASSWORD = $5

echo "Validating disk $DISK"

# check if the disk is actually a disk
if [ ! -b $DISK ]; then
  echo "Error: $DISK is not a block device"
  exit 1
fi

echo "Beginning installation of Arch Linux for $HOSTNAME on $DISK"

# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $DISK
  g # setup a gpt partition table
  n # new partition (efi partition)
  p # primary partition
    # default - 1st partition
    # default - starts at beginning of disk
  +512M  # efi partition sizew
  t # change the type of a partition
  ef # set to efi
  n # new partition (rootfs)
  p # primary partition
    # default - 2nd partition
    # default - starts at beginning of available space
    # default - fills disk
  w # write the partition table
  q # and we're done
EOF

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

arch-chroot /mnt <<"EOF"
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