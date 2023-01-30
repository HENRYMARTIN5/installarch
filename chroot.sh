#!/bin/bash

TIMEZONE=$1
HOSTNAME=$2
USERNAME=$3
DRIVE=$4

# set the timezone
ln -sf $TIMEZONE /etc/localtime
hwclock --systohc

# set the hostname
echo $HOSTNAME > /etc/hostname

# hostfile
echo "
# IPv4
127.0.0.1	localhost
127.0.1.1	$HOSTNAME.localdomain $HOSTNAME

# IPv6
::1		localhost" > /etc/hosts

# make a new user and set its password
useradd -m $USERNAME

usermod -aG wheel,audio,video,optical,storage $USERNAME

# uncomment wheel group in sudoers
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

# Install grub
pacman -S grub os-prober freetype2 dosfstools --noconfirm > /dev/null
grub-install $DRIVE
grub-mkconfig -o /boot/grub/grub.cfg

# install network tools
pacman -S dhcpcd net-tools netctl dialog wpa_supplicant networkmanager nm-connection-editor inetutils ifplugd --noconfirm

# enable services
systemctl enable {dhcpcd,NetworkManager,ifplugd}

# install git and other utilities
pacman -S curl wget git sudo
