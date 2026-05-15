 ### THIS IS A WORK IN PROGRESS, UNTIL THIS DISCLAIMER IS REMOVED THESE SCRIPTS WILL LIKELY PRODUCE ERRORS ###

Solitude is built with a minimal lightweight Debian host os, Sway window manager and KVM/QEMU for virtualization, it replaces Xen with a simpler, much lighter stack.
The system emphasizes a minimal browser and network vm, allowing users to isolate untrusted workloads efficiently. Solitude employs isolation through compartmentalization, making advanced security measures efficient and seamless.


### Installation

### Setup Solitude host operating system:

If you do not install a display manager during install the command sudo and rfkill will not be installed.
Upon initial install of the host operating system, reboot into system, `apt install sudo -y && usermod -aG sudo $USER` then logout/in or reboot.
If you cannot connect to wifi network after install run command `rfkill list` if it returns "rfkill not installed" you will need to either connect to ethernet and `apt install -y rfkill` or copy rfkill binary into /sbin to unblock the wifi card with `rfkill unblock <card id number from rfkill list>`

```bash
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/host-os/install.sh | bash
```

### Setup Solitude network vm:

After host setup is complete, install a minimal debian virtual machine in virt-manager. only needs 20GB.

It would be wise to pass your wireless and/or ethernet card through to the vm rather than use the host's virtual ethernet, this will auto populate your network configs. 

To avoid unnecessary work "prior to running the below script" cp /var/lib/libvirt/images/network.qcow2 to /var/lib/libvirt/images/browser.qcow2
You now have a template for the browser vm.

```bash
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/network-vm/install.sh | bash
```

### Setup Solitude browser vm:

The browser is pretty dang basic, just add existing browser.qcow2, check box for "configure before install", then "add hardware", at the very bottom add "virtio vsock".
This forwards the browser window through to the host os.
This would also be a good time to enable OpenGl in Display Spice and 3D acceleration in Video Virtio to enable hardware acceleration in the browser.

```bash
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/browser-vm/install.sh | bash
```
