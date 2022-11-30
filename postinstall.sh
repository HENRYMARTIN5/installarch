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

# Install the respective shell
if [ "$SHELL" = "bash" ]; then
    echo "Installing Bash..."
    pacman -S bash --noconfirm
    echo "Done!"
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
echo "Installing other utils..."
pacman -S firefox vlc libreoffice-fresh gimp inkscape gparted p7zip unrar unzip zip --noconfirm
echo "Done!"

echo "Installing yay..."
su $SUDO_USER -c "git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm" || {
    echo "Could not install yay" >/dev/stderr
}
echo "Done!"



# Enable NetworkManager
echo "Enabling NetworkManager..."
systemctl enable NetworkManager

echo "Enabling Display Manager..."
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

echo "Successfully tweaked system config and installed desktop environment."
echo "I use Arch, btw."