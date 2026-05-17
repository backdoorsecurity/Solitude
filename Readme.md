 ### THIS IS A WORK IN PROGRESS, UNTIL THIS DISCLAIMER IS REMOVED THESE SCRIPTS WILL LIKELY PRODUCE ERRORS ###

Solitude is designed for linux power users that require the isolated security model of Qubes os who prefer the cli over gui.
This is not a plug and play iso but rather a collection of scripts to be run on a fresh install of debian/derivative host and vm's. Your hardware must support pci passthrough.

Featuring the Sway window manager with KVM/QEMU virtualization, it replaces Qubes Xen with a simpler, much lighter stack.

The system employs a minimal lightweight browser and network vm. Emphasizing isolation through compartmentalization, making advanced security measures efficient and seamless.

Ideally all communication should be done through ssh. Be sure to set up ssh host keys and disable password authentication.
Ssh connections should only be possible from host > vm and/or vm <> vm if needed, never vm > host.



### Installation

### Solitude host operating system:
* I will be making a separate detailed how to on installing the host for maximum performance and stability.

As debian does not ship with sway wm, the preferred method is to skip installing a display manager.

One catch is the command sudo and rfkill will not be installed. If you cannot connect to wifi network after install, execute command "rfkill list", if it returns "rfkill not installed" you will need to either connect to ethernet and `apt install -y rfkill` or copy the rfkill binary into /sbin from a rescue drive to unblock the wifi card with `rfkill unblock <card id number from rfkill list>`.

For this reason I would highly advise preparing a live rescue drive pre install.

Upon initial install of the host operating system, reboot into system. As root: `apt install sudo -y && usermod -aG sudo $USER` then logout/in or reboot and run the install script. "This is neccessary for the script to work, i am working on an updated script which does not require sudo.

# Hotkey map:

`alt+a,s,d,f,g:` `workspaces 1-5`

`alt+q:`         `executes ~/.config/sway/keybindings/browser.kb`

`alt+w,e,r:`      `foot terminal`

`alt+t:`          `virt-manager`

`alt+x:`          `kill window`

`alt+c:`          `copy`

`alt+v:`          `paste`

`alt+"numpad7":`  `internet mode:  allow host network access`

`alt+"numpad4":`  `isolated mode:  deny host network access, allow vm's access network`

`alt+"numpad1":`  `airgapped mode: disable all external network access, host <> vm <> vm communication through all ports`

`these can be changed in ~/.config/sway/config and ~/.config/sway/keybindings`

```bash
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/host-os/install.sh | bash
```



### Solitude network vm:

After host setup is complete, install a minimal debian virtual machine in virt-manager. only needs ~20GB. You may want more if you intend to install snort3 or other large security programs.

It would be wise to pass your wireless and/or ethernet card through to the vm rather than use the host's virtual ethernet, this will auto populate your wireless/ethernet network configs. 
The host install script automatically detects the pci ids and adds them to the vfio/iommu kernel parameters.

To avoid unnecessary work "prior to running the below script" cp /var/lib/libvirt/images/network.qcow2 to /var/lib/libvirt/images/browser.qcow2
You now have a template for the browser vm.

I have recently switched to systemd-networkd in the network vm. I will be adding a prompt in the script allowing the user to select the old /etc/network/interfaces or systemd-networkd. "I have had issues with the old network convention".

Depending on your security needs snort3 can also be run in inline/bridged ips mode between the physical and veth ifaces, I will be adding scripts and configs to set this up in the future.

```bash
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/network-vm/install.sh | bash
```



### Solitude browser vm:

With the massive attack surface a web browser presents I have built an extremely restrictive firejail sandbox profile in ~/.config/firejail/brave.

While any web browser can be used, my browser start script is optimized for chrome based browsers. Specifically brave-browser. While any browser could be configured in ~/.config/sway/keybindings/browser.kb, the firejail configs may work for any chrome based browsers as well with miminal tweaks to blacklisting files for the browser binaries. also make sure to add paths to ~/.config/firejail/brave/blacklists/home.db that should not be accessible by the web browser.
You can check accessible directories my entering "file:///" into url bar and explore your filesystem as the browser can.

Setting up the browser is pretty dang basic, just add existing browser.qcow2 in virt-manager gui, check box for "configure before install", then "add hardware", at the very bottom add "virtio vsock". This forwards the browser window through to the host os.
The command to start the web browser is sent via ssh to the browser vm, it is neccessary to set ssh hostkeys.
This would also be a good time to enable OpenGl in Display Spice and 3D acceleration in Video Virtio to enable hardware acceleration in the web browser.
You can verify acceleration by entering brave://gpu in url bar.

```bash
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/browser-vm/install.sh | bash
```
