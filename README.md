
# installarch
script to install arch linux on your pc with a bunch of extra goodies

### Disclaimer
Short warning: This is optimized for my various installations of Arch in VMs. It works 9/10 times on normal PCs, but just to be safe, read through everything. Got it? Good. Let's get started.

Oh, also keep in mind that if you want a minimal arch installation, this is not for you. This does a lot of the hard work automatically and installs enough packages to justify itself as its own spin of Arch (not as sophisticated as some other spins, but still a spin nevertheless).

Pro tip: If you know what you're doing, you can just look at the headings of each of the steps and follow the process much more loosely.

Wanna know what this script is doing? Check out [the bottom of this README](https://github.com/HENRYMARTIN5/installarch#features-of-this-script), it contains a list of everything installed and modified from the base configuration.

### Step 1: Get a USB Drive and load Arch
Obtain a USB drive. You probably have one lying around. If a USB drive won't do, you can use a MicroSD/SD card, DVD, or other removable media. Download a copy of [Rufus](https://rufus.ie/en/#) and burn the [Arch Linux ISO](https://archlinux.org/download/) to it.

### Step 2: Boot into the USB drive, then partition the drive
Reboot your machine. Spam the function keys (F1-F12) and select your removable medium. You should be dropped into a command line.

Now, we need to partition the drive you're using. To begin, run `fdisk /dev/sdx`, with `sdx` replaced with the drive you want to format.

Now, run the following commands:

```
o
w
```

If this warns you about "This device contains 'gpt' signature and it will be removed by a write command" ignore it. It should still work fine.

This will create a new partition table. Now, run `cfdisk /dev/sdx`, and select `dos`.

Use your arrow keys and select `New`, accept the default partition size (the entire disk), and select `primary`. Select `Write` type `yes` and press enter. Then, select `Quit`.

### Step 3: Connect to the internet and download this repo
There are many ways you can do this. This guide covers some of the more common ones. If you're in a VM and didn't select "Bridged Adapter" mode, then you're probably already connected to the internet. Run `ping google.com` to test your connection. If you selected "Bridged Adapter" mode, then you're probably good to run `dhcpcd` and connect.

If you're not in a VM but have an Ethernet cable connected, chances are also that you can connect using `dhcpcd`. If that doesn't work, we can resort to a WiFi connection. Run `iwctl`. Now, at the new prompt, type `device list`. It should print a list of network interfaces on your device. 

Next, scan for networks. Choose a device from the list, and run `station [DEVICE] scan` with `[DEVICE]` being replaced by the network interface you chose.

Then run `station [DEVICE] get-networks` to print out a list of available networks. To connect to a network, run `station [DEVICE] connect [SSID]`.

Finally, run `ping google.com`. If that works, run `timedatectl set-ntp true` to sync the system clock.

### Step 4: Clone this repo and run the script

Run:

```sh
pacman -Sy
pacman -S git --noconfirm
git clone https://github.com/HENRYMARTIN5/installarch.git
cd installarch
chmod +x installarch.sh
```

Before we actually install it, there are a few things you need to know:

- You need to choose a hostname. This is the name of your computer. It can be anything you want, but it's recommended to keep it short and simple. For example, `mylaptop` or `mydesktop`.
- You need to choose a username. This is the name of the user you will be using. It can be anything you want, but it's recommended to keep it short and simple. For example, `hacker` or `bob`.
- You also need to choose a root password. This will be the password for the root user (which can be the same as your user password).
- You also need to choose a user password. This will be the password for your user (which you specified the username of earlier).
- You also need to choose a drive to install it to, for instance, `/dev/sda`.

Now, run the script:

```sh
./installarch.sh [DRIVE] [HOSTNAME] [USERNAME]
```

You will eventually be asked to enter a root password, then a user password.

### Step 5: Reboot into your shiny new Arch Linux install and connect to the internet again, if necessary (but we're not done yet)!

First, we need to reboot the system. Run the command:

```sh
reboot
```

You should have been dropped into a login screen. Log in with the user username and password you chose earlier.

Now, run `ping google.com`. If this works, move on to the next step. If not, follow the instructions in the first bit of Step 3 to connect to the internet again.

### Step 6: Clone this repo again and run the post-install script

But first, we need to install git again, because our fresh install doesn't contain it.

```sh
sudo pacman -S wget curl git --noconfirm
```

Now, clone the repo and move into it:

```sh
git clone https://github.com/HENRYMARTIN5/installarch.git
cd installarch
chmod +x postinstall.sh
```

And finally, run the script, passing it your GPU brand (AMD, Intel, or Nvidia) and the desktop environment. We'll quickly dive into what each of the DEs look like so you can properly choose the one you want.

- Budgie (`budgie`) ![image](https://user-images.githubusercontent.com/62612165/204823121-d625b61b-d2ed-4fd8-abdd-6b5ea528ed42.png)
- Cinnamon (`cinnamon`) ![image](https://user-images.githubusercontent.com/62612165/204823321-c6b06a4c-49e9-4e2b-920c-f40fa6ebde81.png)
- Deepin (`deepin`) ![image](https://user-images.githubusercontent.com/62612165/204823530-3ea1d145-3d45-4c98-875a-448ba751b81d.png)
- GNOME (`gnome`) ![image](https://user-images.githubusercontent.com/62612165/204824358-6b78972f-5470-4f59-9359-c2258e9c2b16.png)
- KDE Plasma (`plasma`) ![image](https://user-images.githubusercontent.com/62612165/204823929-e3a8ac69-8940-4027-889a-d90dd1df3a3a.png)
- LXDE (`lxde`) ![image](https://user-images.githubusercontent.com/62612165/204824088-35d15337-233e-4e56-83df-52065e23ed4b.png)
- LXQt (`lxqt`) ![image](https://user-images.githubusercontent.com/62612165/204824615-4149207b-370b-4350-b4c9-63d7b701aebf.png)
- MATE (`mate`) ![image](https://user-images.githubusercontent.com/62612165/204824969-7eff12ee-ec0a-4b9b-9b08-72c8f6004ea3.png)
- Xfce (`xfce`) ![image](https://user-images.githubusercontent.com/62612165/204825545-37870b45-70bf-4d59-8618-b2348e0acfda.png)


I personally recommend KDE Plasma for experienced Windows users, LXQt for people running on VMs or other less powerful machines, GNOME for people wanting a minimalist, modern desktop with a bit of a different layout, and Xfce for people who want to use Arch for development due to its powerful tiling manager. If you want a somewhat Windows-esque experience with a bit of a switched up feature set, I recommend looking into Budgie, which mimics GNOME in functionality (it was based on GNOME, actually) but adds features that will require some adjusting to from windows.

TL;DR: KDE Plasma for Windows users, LXQt for less powerful machines, GNOME for something modern, Xfce for development, Budgie for Windows-esque with added features.

Chose one? Great! Find its ID (it's in parentheses after the name) and remember it. You'll need it later.

Next up, you need to choose a shell. The options are `bash` (which is preinstalled), `zsh`, and `fish`. Chose whichever one you like (or just stick with bash if you don't know what I'm talking about). If you choose to use `zsh`, `oh-my-zsh` will also be installed.

Enter all of this information into the following command:

```sh
./postinstall.sh [DESKTOP] [GPUBRAND] [SHELL]
```

If everything works well, you should be dropped into a graphical login screen. Log in with the credentials you chose earlier and enjoy your chosen desktop.

### Step 7: Celebrate!

Yay! You just installed Arch Linux! Revel in your glory for now you may utter the glorious words:

```
.__                                                 .__           ___.    __           
|__|    __ __  ______ ____     _____ _______   ____ |  |__        \_ |___/  |___  _  __
|  |   |  |  \/  ___// __ \    \__  \\_  __ \_/ ___\|  |  \        | __ \   __\ \/ \/ /
|  |   |  |  /\___ \\  ___/     / __ \|  | \/\  \___|   Y  \       | \_\ \  |  \     / 
|__|   |____//____  >\___  >   (____  /__|    \___  >___|  / /\    |___  /__|   \/\_/  
                  \/     \/         \/            \/     \/  )/        \/              
```

## Features of this script

#### `installarch.sh`

- Installs base packages with `pacstrap` (`base`, `base-devel`, `linux`, `linux-firmware`, `linux-headers`, `man-db`, `man-pages`, `bash-completion`)
- Generates `fstab`
- Automatically chroots into the new install using `arch-chroot`
- Sets the timezone to the original host timezone
- Sets the system hostname
- Creates a hostfile
- Sets the root password
- Creates a user and sets its password, also adds it to `sudoers`
- Installs Grub2 to the disk
- Installs networking tools
 
#### `postinstall.sh`

- Installs the specified desktop environment and the required drivers for the system GPU, as well as a display manager compatible with that desktop environment
- Installs various audio drivers
- Enables `command-not-found` and `autocd`
- Installs the shell of the user's choice (`bash`, `zsh`, or `fish`)
- If zsh is installed, also installs `oh-my-zsh`, `zsh-autocompletion`, and `zsh-syntax-hilighting`
- Sets default shell to chosen shell
- Installs TOR, Firefox
- Installs Discord and Thunderbird
- Installs `libreoffice-fresh`, `gimp`, `inkscape`, and `gparted`
- Installs `p7zip`, `unrar`, `unzip`, and `zip`
- Installs `yay`, an AUR helper
- Enables `NetworkManager`
- Automatically launches the display manager
- Enables the pacman color output / progress bar easter egg
- Enables pacman multilib
- Installs `neofetch` and `hyfetch`
- Installs a variety of fonts, including the microsoft core fonts (using `ttf-ms-fonts` on the AUR)
- Installs Wine, winetricks, and Lutris
- Installs Steam and the Proton compatibility layer
- Installs Amarok and VLC
- Downloads and installs the latest Nvidia drivers
- Downloads and installs the latest AMD drivers
- Downloads and installs the latest Intel drivers
- Installs `neovim`, `python`, and `kitty`
- Installs `openssh` and `telnet`
