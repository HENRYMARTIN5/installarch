#!/bin/bash

# get parameters

DISK=$1
HOSTNAME=$2
USERNAME=$3

echo "Validating disk $DISK"

# check if the disk is a block device
if [ ! -b $DISK ]; then
  echo "Error: $DISK is not a block device"
  exit 1
fi

echo "Beginning installation of Arch Linux for $HOSTNAME on $DISK"

# now, we need to format the partitions

mkfs.ext4 ${DISK}1 # rootfs partition (ext4)

# mount rootfs partition

mount ${DISK}1 /mnt


# pacstrap

pacstrap /mnt base base-devel linux linux-firmware linux-headers man-db man-pages bash-completion

# fstab

genfstab -U /mnt >> /mnt/etc/fstab

# get the host timezone

TIMEZONE=$(readlink -f /etc/localtime)

# copy the chroot script to the new system
cp ./chroot.sh /mnt/root/installarch_chroot.sh

# chroot in and run chroot.sh

arch-chroot /mnt <<EOF
chmod +x /root/installarch_chroot.sh
cd /root
./installarch_chroot.sh $TIMEZONE $HOSTNAME $USERNAME $DISK
exit
EOF


echo "Installation complete. Set a root password, unmount the partitions, and reboot."
