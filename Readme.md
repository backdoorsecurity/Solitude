 ### THIS IS A WORK IN PROGRESS, UNTIL THIS DISCLAIMER IS REMOVED THESE SCRIPTS WILL LIKELY PRODUCE ERRORS ###

Solitude is built with a minimal lightweight Debian host os, Sway window manager and KVM/QEMU for virtualization, it replaces Xen with a simpler, much lighter stack.
The system emphasizes a minimal browser and net vm, allowing users to isolate untrusted workloads efficiently. Solitude employs isolation through compartmentalization, making advanced security measures efficient and seamless.

After installing the host operating system, reboot into system, install sudo and run usermod -aG sudo $USER. then reboot. You must follow this for all vms as well.

after running the host operating system script install a minimal debian virtual machine in virt-manager. only needs ~10-20GB.
to avoid unnecessary work you could cp /var/lib/libvirt/images/net-vm.qcow2 to /var/lib/libvirt/images/browser-vm.qcow2

net-vm:
In virt-manager add hardware section navigate to pci devices, locate your wifi and ethernet card. pass both through to the net-vm. you may not be able to add the ethernet card without adding the other devices from the iommu group or breaking the group apart.

### Installation

Install Solitude host operating system:

```bash
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/host-os/install.sh | bash
```

install Solitude net-vm

```bash
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/net-vm/install.sh | bash
```

install Solitude browser-vm

```bash
curl -fsSL https://raw.githubusercontent.com/backdoorsecurity/Solitude/main/browser-vm/install.sh | bash
```
