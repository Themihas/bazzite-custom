#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

# Directly from the Fedora install guide. I have not had much luck, with the more "proper" DistroBox based install.
# Specifically, I have not been able to get the netbird-ui to work.
# https://docs.netbird.io/get-started/install/linux#fedora-amazon-linux-2023-dnf
tee /etc/yum.repos.d/netbird.repo <<EOF
[netbird]
name=netbird
baseurl=https://pkgs.netbird.io/yum/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.netbird.io/yum/repodata/repomd.xml.key
repo_gpgcheck=1
EOF

# Use --setopt=tsflags=noscripts to skip the %post scriptlet which tries to
# start the netbird service during build (systemd is not running in containers).
# Enable the service manually when needed with: systemctl enable --now netbird
dnf5 -y install --setopt=tsflags=noscripts libappindicator-gtk3 libappindicator netbird-ui

# Installing sync software for Mega.io
# Use --setopt=tsflags=noscripts to skip the %post scriptlet which fails in container builds
# (tries to import GPG keys and set sysctl values which are not permitted)
# wget https://mega.nz/linux/repo/Fedora_43/x86_64/megasync-Fedora_43.x86_64.rpm && dnf5 -y install --setopt=tsflags=noscripts "$PWD/megasync-Fedora_43.x86_64.rpm"
wget https://mega.nz/linux/repo/Fedora_44/x86_64/megasync-Fedora_44.x86_64.rpm && dnf5 -y install --setopt=tsflags=noscripts "$PWD/megasync-Fedora_44.x86_64.rpm"
rm megasync-Fedora_44.x86_64.rpm

#### Example for enabling a System Unit File

/usr/bin/netbird service install
systemctl daemon-reload
systemctl enable netbird
systemctl enable podman.socket
