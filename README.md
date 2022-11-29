# installarch
script to install arch linux on your pc

### Disclaimer
Short warning: This is optimized for my various installations of Arch in VMs. It works 9/10 times on normal PCs, but just to be safe, read through everything. Got it? Good. Let's get started.

Pro tip: If you know what you're doing, you can just look at the headings of each of the steps and follow the process much more loosely.

### Step 1: Get a USB Drive and load Arch
Obtain a USB drive. You probably have one lying around. If a USB drive won't do, you can use a MicroSD/SD card, DVD, or other removable media. Download a copy of [Rufus](https://rufus.ie/en/#) and burn the [Arch Linux ISO](https://archlinux.org/download/) to it.

### Step 2: Boot into the USB drive and ensure that it booted in UEFI mode
Reboot your machine. Spam the function keys (F1-F12) and select your removable medium. You should be dropped into a command line. Run the following command:

```sh
ls /sys/firmware/efi/efivars
```

If this command works without errors, proceed. Otherwise, look in your BIOS for a setting called "Perfered Boot Mode". It is comfirmed to be in both the Thinkpad and Dell BIOS.

### Step 3: Connect to the internet and download this repo
There are many ways you can do this. This guide covers some of the more common ones. If you're in a VM and didn't select "Bridged Adapter" mode, then you're probably already connected to the internet. Run `ping google.com` to test your connection. If you selected "Bridged Adapter" mode, then you're probably good to run `dhcpcd` and connect.

If you're not in a VM but have an ethernet cable connected, chances are also that you can connect using `dhcpcd`. If that doesn't work, we can resort to a WiFi connection. Run `iwctl`. Now, at the new prompt, type `device list`. It should print a list of network interfaces on your device. 

Next, scan for networks. Choose a device from the list, and run `station [DEVICE] scan` with `[DEVICE]` being replaced by the network interface you chose.

Then run `station [DEVICE] get-networks` to print out a list of available networks. To connect to a network, run `station [DEVICE] connect [SSID]`.

Finally, run `ping google.com`. If that works, run `timedatectl set-ntp true` to sync the system clock.

### Step 4: Clone this repo and run the script

TODO. No script exists yet.
