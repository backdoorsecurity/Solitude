<h1 align="center">
  <---------- SOLITUDE ---------->
</h1>
<h2 align="center">
The operating system for hermits who never get laid.  
</h2>  
<h3 align="center">  
Hello and welcome fellow linux users, I bring to you, an operating system configuration, designed for linux power  
users who seek the isolated security model of QubesOs but prefer a light snappy cli. This is not a plug and play  
iso but rather a collection of scripts to be run on a fresh install of debian/derivative host/vm's.  
For this configuration to work, your hardware must support pci passthrough.  
Featuring Sway wm and KVM/QEMU virtualization, a minimal lightweight browser and network vm. this  
replaces the Qubes Xen Model with a much lighter stack.  
this security model is known as "isolation through compartmentalization",  
the most advanced computer security system on the planet.  
<h3 align="center">  
Computers are kinda my jam, this system is still rough around the edges, but...

I really enjoy using it and it is only going to get better.
</h3>  
  
  
<h2 align="center">!!! UNTIL THIS DISCLAIMER IS REMOVED, THESE SCRIPTS WILL LIKELY PRODUCE ERRORS !!!  
It would be wise to carefully read the scripts and check the config files before you install this on bare metal.
</h2>  
  
<h2 align="center">INSTALLATION</h2>  
  <br>
  
  
<h1 align="center">  
|-------------- HOST OPERATING SYSTEM ----------------|  
</h1>  
  
  
  
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
  
<h2 align="center">HOTKEY MAP:</h2>

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
  
<h3 align="center">
Ideally all inter-machine communication would be done through ssh. Be sure to set up ssh host keys and  
disable password auth. Ssh connections should only be allowed from

host > vm and/or vm <> vm if needed, never vm > host.  
</h3>  
  
<h3 align="center">INSTALL</h3>  
  
  
```  
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/host-os/install.sh | bash  
```
  
  <br>
  <br>
  
  
<h1 align="center">|----------------------- NETWORK VM -----------------------|</h1>  
  
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
  
  
  
<h3 align="center">INSTALL</h3>  
  
  
```
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/network-vm/install.sh | bash  
```
  
<br>
<br>
<h1 align="center">|----------------------- BROWSER VM -----------------------|</h1>
<br>
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
  
  
  
<h4 align="center">INSTALL</h4>  
  
```
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/browser-vm/install.sh | bash
```
  
  
  
  
<h1 align="center">|------------NETWORK MAP------------|</h1>  
  
  
  
  <h2 align="center"> UNDER CONSTRUCTION</h2>
