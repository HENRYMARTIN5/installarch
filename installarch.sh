echo "Beginning installation on /dev/sda"

# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
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

mkfs.fat -F32 /dev/sda1 # efi partition (fat32)
mkfs.ext4 /dev/sda2 # rootfs partition (ext4)

# mount partitions

mount /dev/sda1 /mnt/boot/efi
mount /dev/sda2 /mnt

# pacstrap

pacstrap /mnt base base-devel linux linux-firmware linux-headers man-db man-pages bash-completion

# fstab

genfstab -U /mnt >> /mnt/etc/fstab

# chroot in

arch-chroot /mnt <<"EOF"
pacman -Sy vim zsh --noconfirm

EOF
