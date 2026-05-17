# Firejail profile for brave
# Description: Web browser that blocks ads and trackers by default.

# noexec /tmp is included in chromium-common.profile and breaks Brave
ignore noexec /tmp
# TOR is installed in ${HOME}.
# Note: chromium-common.profile enables apparmor. To keep that intact,
# uncomment the 'brave + tor' rule in /etc/apparmor.d/local/firejail-default.
# Alternatively you can add 'ignore apparmor' to your brave.local.
ignore noexec ${HOME}
# Causes slow starts (#4604)
ignore private-cache

noblacklist ${HOME}/.cache/BraveSoftware
noblacklist ${HOME}/.config/BraveSoftware
noblacklist ${HOME}/.config/brave
noblacklist ${HOME}/.config/brave-flags.conf
noblacklist ${HOME}/.config/mimeapps.list
noblacklist ${HOME}/.local/share/applications/mimeapps.list

# noblacklist hardware accel paths
#noblacklist /usr/share/vulkan/icd.d
#noblacklist /usr/lib/x86_64-linux-gnu

# Common additional paths
#noblacklist /usr/share/glvnd
#whitelist /usr/share/glvnd
# brave uses gpg for built-in password manager
noblacklist ${HOME}/.gnupg

mkdir ${HOME}/.cache/BraveSoftware
mkdir ${HOME}/.config/BraveSoftware
mkdir ${HOME}/.config/brave
whitelist ${HOME}/.cache/BraveSoftware
whitelist ${HOME}/.config/BraveSoftware
whitelist ${HOME}/.config/brave
whitelist ${HOME}/.config/brave-flags.conf
whitelist ${HOME}/.config/mimeapps.list
whitelist ${HOME}/.local/share/applications/mimeapps.list
whitelist ${HOME}/.gnupg

# whitelist hardware accel paths
#whitelist /usr/lib/x86_64-linux-gnu/dri
#whitelist /usr/share/vulkan
#whitelist /usr/share/vulkan/icd.d
#whitelist /dev/dri
#whitelist /dev/dri/card0
#whitelist /dev/dri/renderD128

# Brave sandbox needs read access to /proc/config.gz
noblacklist /proc/config.gz

# mpris
dbus-user.own org.mpris.MediaPlayer2.brave.*

# Redirect
#include ${HOME}/.config/firejail/brave/blink-common-hardened.inc.profile
include ${HOME}/.config/firejail/brave/blacklist/bin.db
include ${HOME}/.config/firejail/brave/blacklist/boot.db
include ${HOME}/.config/firejail/brave/blacklist/dev.db
include ${HOME}/.config/firejail/brave/blacklist/etc.db
include ${HOME}/.config/firejail/brave/blacklist/home.db
#include ${HOME}/.config/firejail/brave/blacklist/proc.db
include ${HOME}/.config/firejail/brave/blacklist/root.db
#include ${HOME}/.config/firejail/brave/blacklist/run.db
include ${HOME}/.config/firejail/brave/blacklist/sbin.db
#include ${HOME}/.config/firejail/brave/blacklist/srv.db
include ${HOME}/.config/firejail/brave/blacklist/sys.db
#include ${HOME}/.config/firejail/brave/blacklist/usr.db
#include ${HOME}/.config/firejail/brave/blacklist/var.db
