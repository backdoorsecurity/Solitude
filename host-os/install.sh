#!/bin/bash
# Host setup for a systemd-boot machine. Run as the regular user; sudo is used
# where root is required. Passwordless sudo is installed on purpose.

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

if [[ $(id -u) -eq 0 ]]; then
    echo 'Run this as your regular user. The script calls sudo itself.' >&2
    exit 1
fi

USER=$(id -un)
home=$(getent passwd "$USER" | cut -d: -f6)
if [[ -n $home ]]; then
    HOME=$home
fi

IFACE=br0
IP_ADDRESS=10.10.10.0
NETMASK=255.255.255.240
IP_ROUTE=10.10.10.1
NAMESERVER=1.1.1.1
MTU=9000

merge_cmdline() {
    local -A values=()
    local -a order=()
    local token key
    for token in "$@"; do
        [[ -n $token ]] || continue
        case $token in
            BOOT_IMAGE=*|initrd=*) continue ;;
        esac
        if [[ $token == *=* ]]; then
            key=${token%%=*}
        else
            key=$token
        fi
        if [[ -z ${values[$key]+x} ]]; then
            order+=("$key")
        fi
        values[$key]=$token
    done
    local -a out=()
    for key in "${order[@]}"; do
        out+=("${values[$key]}")
    done
    printf '%s\n' "${out[*]}"
}

read_cmdline_file() {
    tr -s '[:space:]' ' ' <"$1" | sed 's/^ //;s/ $//'
}

echo 'installing packages'
sudo apt-get update
sudo apt-get dist-upgrade -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold
sudo apt-get autoremove -y
sudo apt-get install -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold \
    "linux-headers-$(uname -r)" \
    virt-manager \
    git \
    wget \
    curl \
    sway \
    waybar \
    wtype \
    bridge-utils \
    foot \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    copyq \
    wf-recorder \
    oxygencursors \
    qt6ct \
    waypipe \
    lm-sensors \
    pciutils \
    iptables

echo 'detecting pci ids for vfio'
lspci -nn >/dev/null
pci_ids=$(lspci -nn | grep -iE 'Ethernet|Network controller|Wi-?Fi|Wireless|NVIDIA' | grep -oP '\[\K[0-9a-f]{4}:[0-9a-f]{4}' | sort -u || true)
if [[ -z $pci_ids ]]; then
    echo 'No Ethernet, Wi-Fi, or NVIDIA PCI ids were found.' >&2
    lspci -nn >&2 || true
    exit 1
fi
PCI_IDS=$(printf '%s\n' "$pci_ids" | paste -sd, -)
echo "vfio-pci.ids=${PCI_IDS}"

echo 'creating config dir'
mkdir -p "$HOME/.config"

echo 'installing dot-files'
script_path=${BASH_SOURCE[0]:-}
if [[ -n $script_path && -d "$(dirname "$script_path")/dot-files" ]]; then
    SRC=$(cd "$(dirname "$script_path")" && pwd)
else
    rm -rf /tmp/Solitude
    git clone --depth 1 https://github.com/backdoorsecurity/Solitude.git /tmp/Solitude
    SRC=/tmp/Solitude/host-os
fi
cp -a "$SRC/dot-files/.config/." "$HOME/.config/"
cp -a "$SRC/dot-files/".z* "$HOME/"
sudo cp -a "$SRC/dot-files/.zshrc" /root/.zshrc
chmod +x "$HOME/.config/sway/scripts/pwr_perf.sh" "$HOME/.config/sway/scripts/startup.sh"

echo 'setting up passwordless sudo'
sudoers_tmp=$(mktemp)
printf '%s\n' "$USER ALL=(ALL) NOPASSWD: ALL" >"$sudoers_tmp"
sudo visudo -cf "$sudoers_tmp"
sudo install -m 0440 "$sudoers_tmp" /etc/sudoers.d/solitude
rm -f "$sudoers_tmp"

echo 'setting up autologin'
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${USER} --noclear %I 38400 linux
EOF

echo 'installing system service files'
if [[ ! -x $HOME/.config/sway/scripts/pwr_perf.sh ]]; then
    echo "missing executable $HOME/.config/sway/scripts/pwr_perf.sh" >&2
    exit 1
fi
sudo tee /etc/systemd/system/startup.service >/dev/null <<EOF
[Unit]
Description=Apply system and network profiles
After=sysinit.target

[Service]
Type=oneshot
ExecStart=${HOME}/.config/sway/scripts/startup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
sudo tee /etc/systemd/system/pwr_perf.service >/dev/null <<EOF
[Unit]
Description=Switch cpu turbo and energy bias based on ac/battery
After=sysinit.target

[Service]
Type=simple
ExecStart=${HOME}/.config/sway/scripts/pwr_perf.sh
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
# startup.sh removes machine-specific PCI devices; br0 is configured below instead.
sudo systemctl enable pwr_perf.service

echo 'switching shell to zsh'
sudo usermod -s /usr/bin/zsh "$USER"
groups=()
for group in libvirt-qemu libvirt video render; do
    if getent group "$group" >/dev/null; then
        groups+=("$group")
    else
        echo "group ${group} does not exist; skipping" >&2
    fi
done
if [[ ${#groups[@]} -gt 0 ]]; then
    joined=$(IFS=,; echo "${groups[*]}")
    sudo usermod -aG "$joined" "$USER"
fi

echo 'setting kernel command line for systemd-boot'
if [[ -s /etc/kernel/cmdline ]]; then
    base=$(read_cmdline_file /etc/kernel/cmdline)
elif [[ -s /usr/lib/kernel/cmdline ]]; then
    base=$(read_cmdline_file /usr/lib/kernel/cmdline)
else
    base=$(read_cmdline_file /proc/cmdline)
fi
if [[ $base != *root=* ]]; then
    base=$(read_cmdline_file /proc/cmdline)
fi
read -r -a base_tokens <<< "$base"
extra_tokens=(
    intel_iommu=on
    iommu.passthrough=1
    "vfio-pci.ids=${PCI_IDS}"
    net.ifnames=0
    pcie_aspm=force
    memtest=0
    tsx=on
    ipv6.disable=1
)
new_cmd=$(merge_cmdline "${base_tokens[@]}" "${extra_tokens[@]}")
if [[ $new_cmd != *root=* ]]; then
    echo 'refusing to write /etc/kernel/cmdline without a root= parameter' >&2
    exit 1
fi
printf '%s\n' "$new_cmd" | sudo tee /etc/kernel/cmdline >/dev/null

printf '%s\n' 'options kvm_intel nested=1' | sudo tee /etc/modprobe.d/kvm.conf >/dev/null
{
    printf 'options vfio-pci ids=%s\n' "$PCI_IDS"
    printf '%s\n' \
        'softdep drm pre: vfio-pci' \
        'softdep nvidia pre: vfio-pci' \
        'softdep nouveau pre: vfio-pci' \
        'softdep snd_hda_intel pre: vfio-pci' \
        'softdep iwlwifi pre: vfio-pci' \
        'softdep iwlmvm pre: vfio-pci' \
        'softdep e1000e pre: vfio-pci' \
        'softdep igc pre: vfio-pci' \
        'softdep r8169 pre: vfio-pci'
} | sudo tee /etc/modprobe.d/vfio.conf >/dev/null

sudo touch /etc/initramfs-tools/modules
for module in vfio vfio_iommu_type1 vfio_pci; do
    if ! grep -qxF "$module" /etc/initramfs-tools/modules; then
        printf '%s\n' "$module" | sudo tee -a /etc/initramfs-tools/modules >/dev/null
    fi
done

sudo modprobe kvm_intel nested=1 || true
sudo modprobe vfio || true
sudo modprobe vfio-pci || true
sudo modprobe vhost_vsock || true
sudo update-initramfs -u -k all

if ! command -v kernel-install >/dev/null; then
    echo 'kernel-install is missing, so systemd-boot entries were not regenerated' >&2
    exit 1
fi
shopt -s nullglob
images=(/boot/vmlinuz-*)
if [[ ${#images[@]} -eq 0 ]]; then
    echo 'no /boot/vmlinuz-* images found; /etc/kernel/cmdline is written but loader entries were not regenerated' >&2
    exit 1
fi
for image in "${images[@]}"; do
    version=${image##*/vmlinuz-}
    if [[ -f /boot/initrd.img-$version ]]; then
        sudo kernel-install add "$version" "$image" "/boot/initrd.img-$version"
    else
        sudo kernel-install add "$version" "$image"
    fi
done

echo "configuring ${IFACE}"
if [[ ! -f /etc/network/interfaces ]]; then
    printf '%s\n' 'source /etc/network/interfaces.d/*' | sudo tee /etc/network/interfaces >/dev/null
elif ! grep -qE '^[[:space:]]*source(-directory)?[[:space:]]+/etc/network/interfaces\.d(/\*)?' /etc/network/interfaces; then
    printf '\n%s\n' 'source /etc/network/interfaces.d/*' | sudo tee -a /etc/network/interfaces >/dev/null
fi
# Drop the broken stanza older versions of this script appended.
sudo sed -i '/^# virtio network$/,/^[[:space:]]*MTU=/d' /etc/network/interfaces
sudo mkdir -p /etc/network/interfaces.d
sudo tee /etc/network/interfaces.d/br0 >/dev/null <<EOF
auto br0
iface br0 inet static
    bridge_ports none
    bridge_stp off
    bridge_fd 0
    bridge_maxwait 0
    address ${IP_ADDRESS}
    netmask ${NETMASK}
    dns-nameservers ${NAMESERVER}
    mtu ${MTU}
    post-up ip route replace default via ${IP_ROUTE} dev br0 onlink || true
    pre-down ip route del default via ${IP_ROUTE} dev br0 || true
EOF

echo 'iptables is installed. iptables-persistent is skipped because its save prompt cannot be answered when this script is piped to bash.'
echo 'Reboot so systemd-boot loads the new command line and vfio binds the passed-through devices.'
