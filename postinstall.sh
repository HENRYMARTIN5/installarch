#!/bin/bash

DESKTOP=$1 # The desktop environment the user wants to install
GPUBRAND=$2 # The GPU brand the user has
SHELL=$3 # The shell the user wants to use

# Check if the user is root
if [ $EUID != 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Check if the user has entered a desktop environment
if [ -z "$DESKTOP" ]; then
    echo "Please enter a desktop environment."
    exit 1
fi

# Check if the user has entered a GPU brand
if [ -z "$GPUBRAND" ]; then
    echo "Please enter a GPU brand."
    exit 1
fi

# Check if the user has entered a shell
if [ -z "$SHELL" ]; then
    echo "Please enter a shell."
    exit 1
fi

# Check if the user has entered a valid desktop environment
if [ "$DESKTOP" != "budgie" ] && [ "$DESKTOP" != "cinnamon" ] && [ "$DESKTOP" != "deepin" ] && [ "$DESKTOP" != "gnome" ] && [ "$DESKTOP" != "plasma" ] && [ "$DESKTOP" != "lxde" ] && [ "$DESKTOP" != "lxqt" ] && [ "$DESKTOP" != "mate" ] && [ "$DESKTOP" != "xfce" ]; then
    echo "Please enter a valid desktop environment. Choose from:"
    echo "budgie, cinnamon, deepin, gnome, plasma, lxde, lxqt, mate, xfce"
    exit 1
fi

# Check if the user has entered a valid GPU brand
if [ "$GPUBRAND" != "amd" ] && [ "$GPUBRAND" != "intel" ] && [ "$GPUBRAND" != "nvidia" ]; then
    echo "Please enter a valid GPU brand. Choose from:"
    echo "amd, intel, nvidia"
    exit 1
fi

# Check if the user has entered a valid shell
if [ "$SHELL" != "bash" ] && [ "$SHELL" != "fish" ] && [ "$SHELL" != "zsh" ]; then
    echo "Please enter a valid shell. Choose from:"
    echo "bash, fish, zsh"
    exit 1
fi

echo "Installing $DESKTOP with $GPUBRAND drivers and $SHELL as a shell."
# Run the respective commands for the desktop environment
if [ "$DESKTOP" = "budgie" ]; then
    echo "Installing Budgie..."
    pacman -S gnome budgie-desktop --noconfirm
elif [ "$DESKTOP" = "cinnamon" ]; then
    echo "Installing Cinnamon..."
    pacman -S cinnamon lightdm --noconfirm
elif [ "$DESKTOP" = "deepin" ]; then
    echo "Installing Deepin..."
    pacman -S deepin deepin-extra networkmanager lightdm --noconfirm
elif [ "$DESKTOP" = "gnome" ]; then
    echo "Installing GNOME..."
    pacman -S gnome gnome-extra networkmanager --noconfirm
elif [ "$DESKTOP" = "plasma" ]; then
    echo "Installing KDE Plasma..."
    pacman -S plasma kde-applications sddm --noconfirm
elif [ "$DESKTOP" = "lxde" ]; then
    echo "Installing LXDE..."
    pacman -S lxde lxdm --noconfirm
elif [ "$DESKTOP" = "lxqt" ]; then
    echo "Installing LXQt..."
    pacman -S lxqt breeze-icons sddm --noconfirm
elif [ "$DESKTOP" = "mate" ]; then
    echo "Installing MATE..."
    pacman -S mate mate-extra lightdm --noconfirm
elif [ "$DESKTOP" = "xfce" ]; then
    echo "Installing Xfce..."
    pacman -S xfce4 xfce4-goodies lightdm --noconfirm
fi

# Run the respective commands for the GPU brand
if [ "$GPUBRAND" = "amd" ]; then
    echo "Installing AMD drivers..."
    pacman -S mesa xf86-input-libinput xf86-video-ati xf86-video-amdgpu vulkan-radeon amd-ucode --noconfirm > /dev/null
    echo "Done!"
elif [ "$GPUBRAND" = "intel" ]; then
    echo "Installing Intel drivers..."
    pacman -S mesa xf86-input-libinput xf86-video-intel vulkan-intel intel-ucode --noconfirm > /dev/null
    echo "Done!"
elif [ "$GPUBRAND" = "nvidia" ]; then
    echo "Installing NVIDIA drivers..."
    pacman -S mesa xf86-input-libinput nvidia xf86-video-nouveau nvidia-utils --noconfirm > /dev/null
    echo "Done!"
fi

pacman -S pulseaudio pulseaudio-alsa alsa-utils --noconfirm > /dev/null # Install audio drivers
pacman -S flac faac wavpack libmad opus libvorbis openjpeg libwebp x265 libde265 x264 libmpeg2 libvpx --noconfirm > /dev/null # Install various codecs

# Enable command-not-found and autocd
echo "Enabling command-not-found and autocd..."

pacman -S pkgfile --noconfirm > /dev/null
pkgfile -u > /dev/null
echo "source /usr/share/doc/pkgfile/command-not-found.bash" >> /etc/bash.bashrc
echo "shopt -s autocd" >> /etc/bash.bashrc

echo "Enabled command-not-found and autocd."

echo "Installing OpenSSH..."
pacman -S openssh --noconfirm > /dev/null
echo "Done!"

# Enable the pacman easter egg and color option
echo "Enabling pacman easter egg and color option..."
sed -i 's/#Color/Color/g' /etc/pacman.conf

# Enable the pacman easter egg by appending ILoveCandy to the end of the file
echo "ILoveCandy" >> /etc/pacman.conf
echo "Done!"

# Enable multilib
echo "Enabling multilib..."
sed -i 's/#\[multilib\]/\[multilib\]/g' /etc/pacman.conf
sed -i 's/#Include = \/etc\/pacman.d\/mirrorlist/Include = \/etc\/pacman.d\/mirrorlist/g' /etc/pacman.conf
echo "Done!"

# Install neofetch
echo "Installing neofetch..."
pacman -S neofetch --noconfirm > /dev/null
echo "Done!"

# Install various fonts
echo "Installing missing fonts..."
pacman -S noto-fonts noto-fonts-cjk ttf-dejavu ttf-liberation ttf-opensans
echo "Done!"

# Install inetutils
echo "Installing inetutils..."
pacman -S inetutils --noconfirm > /dev/null
echo "Done!"

# Install the respective shell
if [ "$SHELL" = "bash" ]; then
    echo "Bash is already installed, skipping additional shell tweaks."
elif [ "$SHELL" = "fish" ]; then
    echo "Installing Fish..."
    pacman -S fish --noconfirm
    echo "Done!"
elif [ "$SHELL" = "zsh" ]; then
    echo "Installing Zsh..."
    pacman -S zsh --noconfirm

    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/loket/oh-my-zsh/feature/batch-mode/tools/install.sh)" -s --batch || {
        echo "Could not install oh-my-zsh" >/dev/stderr
    }

    echo "Installing zsh-autosuggestions..."

    # We're running as root, so we have to run the commands as the $SUDO_USER
    su $SUDO_USER -c "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" || {
        echo "Could not install zsh-autosuggestions" >/dev/stderr
    }
    # Append the plugin to the plugins array in .zshrc
    su $SUDO_USER -c "sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/g' ~/.zshrc" || {
        echo "Could not append zsh-autosuggestions to plugins array in .zshrc" >/dev/stderr
    }

    echo "Installing zsh-syntax-highlighting..."

    # Now we have to do the same with zsh-syntax-highlighting
    su $SUDO_USER -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git && echo \"source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\" >> ${ZDOTDIR:-$HOME}/.zshrc" || {
        echo "Could not install zsh-syntax-highlighting" >/dev/stderr
    }

    echo "Done installing zsh plugins!"
fi

# Set the chosen shell as the default shell
if [ "$SHELL" = "bash" ]; then
    chsh -s /bin/bash
elif [ "$SHELL" = "fish" ]; then
    chsh -s /bin/fish
elif [ "$SHELL" = "zsh" ]; then
    chsh -s /bin/zsh
fi

# Install some other stuff
echo "Installing other productivity utilities..."
pacman -S firefox vlc libreoffice-fresh gimp inkscape gparted p7zip unrar unzip zip --noconfirm
echo "Done!"

echo "Installing yay... (you may have to confirm the installation, just press Y and then enter if prompted)"
su $SUDO_USER -c "git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm" || {
    echo "Could not install yay" >/dev/stderr
}
echo "Done!"

# Use yay to install the microsoft core fonts
echo "Installing Microsoft core fonts using yay... (This may take a while)"
yay -S ttf-ms-fonts --answerdiff=None
echo "Done!"

echo "Installing Hyfetch..."
yay -S hyfetch --answerdiff=None
echo "Done!"

# Install winetricks
echo "Installing winetricks..."
pacman -S winetricks --noconfirm > /dev/null
echo "Done!"

# Install lutris
echo "Installing Lutris..."
pacman -S lutris --noconfirm > /dev/null
echo "Done!"

# Install steam
echo "Installing Steam..."
pacman -S steam --noconfirm > /dev/null
echo "Done!"

# Install Amarok
echo "Installing Amarok..."
pacman -S amarok --noconfirm > /dev/null
echo "Done!"

echo "Installing some other stuff..."
pacman -S thunderbird neovim python kitty --noconfirm > /dev/null
echo "Done!"

echo "Installing TOR..."
pacman -S tor --noconfirm > /dev/null
echo "Done!"

echo "Installing Discord..."
pacman -S discord --noconfirm > /dev/null
echo "Done!"

echo "Installing Spotify..."
pacman -S spotify-launcher --noconfirm > /dev/null
echo "Done!"


# Enable NetworkManager
echo "Enabling NetworkManager..."
systemctl enable {dhcpcd,NetworkManager,ifplugd}

clear
echo "       Successfully tweaked system config and installed desktop environment."
echo
echo ".__                                                 .__           ___.    __           "
echo "|__|    __ __  ______ ____     _____ _______   ____ |  |__        \_ |___/  |___  _  __"
echo "|  |   |  |  \/  ___// __ \    \__  \\_  __ \_/ ___\|  |  \        | __ \   __\ \/ \/ /"
echo "|  |   |  |  /\___ \\  ___/     / __ \|  | \/\  \___|   Y  \       | \_\ \  |  \     / "
echo "|__|   |____//____  >\___  >   (____  /__|    \___  >___|  / /\    |___  /__|   \/\_/  "
echo "                  \/     \/         \/            \/     \/  )/        \/              "
echo
echo "                 installarch was made by @HENRYMARTIN5 on GitHub"
echo "            if this script helped you, leave me a star on the repo."
echo
echo "     a graphical environment will launch once you continue past this screen."
echo "        you can log in with the username and password you chose earlier."
echo
echo "                        press any key to continue"

read -n 1 -s

# Enable the display manager
if [ "$DESKTOP" = "budgie" ] || [ "$DESKTOP" = "gnome" ] then
    systemctl enable gdm
elif [ "$DESKTOP" = "cinnamon" ] || [ "$DESKTOP" = "mate" ] || [ "$DESKTOP" = "xfce" ] || [ "$DESKTOP" = "deepin" ] then
    systemctl enable lightdm
elif [ "$DESKTOP" = "plasma" ] || [ "$DESKTOP" = "lxqt" ] then
    systemctl enable sddm
elif [ "$DESKTOP" = "lxde" ] then
    systemctl enable lxdm
fi

echo "installarch has finished running. if you see this, you have exited your graphical session."
