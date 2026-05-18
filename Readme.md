<h1 align="center">
  < SOLITUDE >
</h1>

<h3 align="center">
 Solitude is a project i began sometime in 2022-2023 when i really got into virtual machines.
 At that time I had no idea I was starting to build my own distro configuration.
 I had just transferred from tryhackme.com to hackthebox.com when i began to ponder the idea of
 setting up a team of ai pentesters.
 I had heard of people doing it but I had never seen it.
 I just didn't like the thought of running ai directly on my hardware.
 At the time i was using my Lenovo P52, after almost a year of trying to pass through the nvidia gpu to a vm
 I had a random idea of trying my legion 5 pro. Installed Debian,
 set the kernel parameters to enable passthrough and unbound the gpu from the host's iommu group. 
 Installed drivers in the vm and had achieved full gpu passthrough.
 The legion 5 pro uses a muxed graphics switch which makes passthrough a breeze.
 At that time I had no idea I was starting to build my own distro configuration.
 I knew when I started my business I was either going to be a successful mechanic or I was going to spend a lot of time on my computer.
 Been on my own for about 2 years now. Worked an average of 1-2 days a week.
 Kinda sucks being slow and having to live a minimalist lifestyle but I just cant work for any more idiots.
 so computers are kinda my jam, and Im hoping this project will shoot me into the tech industry.

 Im building different types of ai pentesting teams. message file: slow and prone to error.
 named pipes: worked decent but the models would jam the pipe. restart. 
 unix domain sockets: very fast but im having trouble forcing ai2 "the executioner" to shut up and work as a team.
 directly starting a model inside of a model: this has the most potential but does not word directly, 
 I have a python script written by grok ai that starts a manager ai who starts 4 executioners.
 I have some work to do before I post all my new configs but getting there. 
</h3>

#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; !!! UNTIL THIS DISCLAIMER IS REMOVED, THESE SCRIPTS WILL LIKELY PRODUCE ERRORS !!!

Solitude is designed for linux power users that require the isolated security model of Qubes os who prefer the cli.
  
This is not a plug and play iso but rather a collection of scripts to be run on a fresh install of debian/derivative host and vm's.
Your hardware must support pci passthrough.
  
Using Sway wm and KVM/QEMU virtualization, this replaces the Qubes Xen Model with a simpler, much lighter stack.

The system utilizes a minimal lightweight browser and network vm. Emphasizing isolation through compartmentalization, making advanced security measures efficient and seamless.
  
Ideally all communication should be done through ssh. Be sure to set up ssh host keys and disable password authentication.

Ssh connections should only be possible from host > vm and/or vm <> vm if needed, never vm > host.



## Installation

### Host operating system:
* I will be making a separate detailed how to on installing the host for maximum performance and stability.
  
As debian does not ship with sway wm, the preferred method is to skip installing a display manager during initial install.

One catch is the command sudo and rfkill will not be installed. If you cannot connect to wifi network after install, execute:
```text
rfkill list
```
if it returns "rfkill not installed" you will need to either connect to ethernet and 
```text
apt install -y rfkill
```
 or copy the rfkill binary into /sbin from a rescue drive to unblock the wifi card with
```text
rfkill unblock <card id number from rfkill list>
```
For this reason I would highly advise preparing a live rescue drive pre install.  
  
  
Upon initial install of the host operating system, reboot into system. As root:
``` text
apt install sudo -y && usermod -aG sudo $USER
```
then logout/in or reboot and run the install script. "This is neccessary for the script to work, i am working on an updated script which does not require sudo.  
  
### Hotkey map:

`alt+a,s,d,f,g:   workspaces 1-5`

`alt+q:           executes ~/.config/sway/keybindings/browser.kb`

`alt+w,e,r:       foot terminal`

`alt+t:           virt-manager`

`alt+x:           kill window`

`alt+c:           copy`

`alt+v:           paste`

`alt+"numpad7":   internet mode:  host<>internet vm's <> internet`

`alt+"numpad4":   isolated mode:  host<x>internet vm's <> internet "default mode"`

`alt+"numpad1":   airgapped mode: host<x>internet vm's <x> internet host <> vm's <> vm's`

`these can be changed in ~/.config/sway/config and ~/.config/sway/keybindings`  
  
  
  
### install
```
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/host-os/install.sh | bash
```
  
  
  
### Solitude network vm:

After host setup is complete, install a minimal debian virtual machine in virt-manager. only needs ~20GB. You may want more if you intend to install snort3 or other large security programs.
  
It would be wise to pass your wireless and/or ethernet card through to the vm rather than use the host's virtual ethernet, this will auto populate your wireless/ethernet network configs. 
The host install script automatically detects the pci ids and adds them to the vfio/iommu kernel parameters.
  
To avoid unnecessary work "prior to running the install script" poweroff the network vm and execute:
```text
cp /var/lib/libvirt/images/network.qcow2 /var/lib/libvirt/images/browser.qcow2
```
You now have a template for the browser vm.
  
  
I have recently switched to systemd-networkd in the network vm. I will be adding a prompt in the script allowing the user to select the old /etc/network/interfaces or systemd-networkd. "I have had issues with the old network convention".
  
  
Depending on your security needs snort3 can also be run in inline/bridged ips mode between the physical and veth ifaces, I will be adding scripts and configs to set this up in the future.  
  
  
### install
```
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/network-vm/install.sh | bash
```
  
  
  
### Solitude browser vm:

With the massive attack surface a web browser presents I have built extremely restrictive firejail sandbox profiles in ~/.config/firejail/brave.

My browser start script is optimized for chrome based browsers. Specifically brave-browser.

My firejail configs will work for any chrome based browsers with miminal tweaks to the blacklisting files located in
```text
~.config/firejail/brave/blacklistings`
```

Make sure to add user paths in /home which should not be accessible by the web browser:
```text
~/.config/firejail/brave/blacklists/home.db
```

You can check accessible directories my entering
```text
file:///
```
into url bar and exploring your filesystem as the browser can.
  
  
  
Setting up the browser is pretty dang basic, just add existing browser.qcow2 in virt-manager gui, check box for `customize configuration before install`, then `add hardware`, at the very bottom add `virtio vsock`. This forwards the browser window through to the host os.
The command to start the web browser is sent via ssh to the browser vm, it is neccessary to set ssh hostkeys.
  
  
  
This would also be a good time to enable OpenGl in Display Spice and 3D acceleration in Video Virtio to enable hardware acceleration in the web browser.
You can verify acceleration by entering
```text
brave://gpu
```
in url bar.  
  
  
  
### install
```
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/browser-vm/install.sh | bash
```
  
  
  
  
##### Solitude is a project i began sometime in 2022-2023 when i really got into virtual machines.
##### At that time I had no idea I was starting to build my own distro configuration.
##### I had just transferred from tryhackme.com to hackthebox.com when i began to ponder the idea of
##### setting up a team of ai pentesters.
##### I had heard of people doing it but I had never seen it.
##### I just didn't like the thought of running ai directly on my hardware.
##### At the time i was using my Lenovo P52, after almost a year of trying to pass through the nvidia gpu to a vm
##### I had a random idea of trying my legion 5 pro. Installed Debian,
##### set the kernel parameters to enable passthrough and unbound the gpu from the host's iommu group. 
##### Installed drivers in the vm and had achieved full gpu passthrough.
##### The legion 5 pro uses a muxed graphics switch which makes passthrough a breeze.
##### At that time I had no idea I was starting to build my own distro configuration.
##### I knew when I started my business I was either going to be a successful mechanic or I was going to spend a lot of >
##### Been on my own for about 2 years now. Worked an average of 1-2 days a week.
##### Kinda sucks being slow and having to live a minimalist lifestyle but I just cant work for any more idiots.
##### so computers are kinda my jam, and Im hoping this project will shoot me into the tech industry.

##### Im building different types of ai pentesting teams. message file: slow and prone to error.
##### named pipes: worked decent but the models would jam the pipe. restart. 
##### unix domain sockets: very fast but im having trouble forcing ai2 "the executioner" to shut up and work as a team.
##### directly starting a model inside of a model: this has the most potential but does not word directly, 
##### I have a python script written by grok ai that starts a manager ai who starts 4 executioners.
##### I have some work to do before I post all my new configs but getting there.
