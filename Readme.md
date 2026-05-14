                                             ### DISCLAIMER ###
 ### THIS IS A WORK IN PROGRESS, UNTIL THIS DISCLAIMER IS REMOVED THESE SCRIPTS WILL LIKELY PRODUCE ERRORS ###

Solitude is built with a minimal lightweight Debian host os, Sway window manager and KVM/QEMU for virtualization, it replaces Xen with a simpler, much lighter stack.

The system emphasizes a minimal browser and net vm, allowing users to isolate untrusted workloads efficiently. Solitude employs isolation through compartmentalization, making advanced security measures efficient and seamless.

After installing the host operating system, install a minimal debian virtual machine in virt-manager. only needs ~10-20GB.
In virt-manager add hardware section navigate to pci devices then locate your wifi and ethernet card. pass both through to the netvm.

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
