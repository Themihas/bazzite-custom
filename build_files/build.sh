#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Enable coprs
dnf5 copr enable dejan/lazygit

# this installs a package from fedora repos
dnf5 install -y tmux wget neovim fish lazygit

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

# Disabling coprs
dnf5 copr disable dejan/lazygit

# Installing sync software for Mega.io 
wget https://mega.nz/linux/repo/Fedora_43/x86_64/megasync-Fedora_43.x86_64.rpm && dnf5 install "$PWD/megasync-Fedora_43.x86_64.rpm"
rm megasync-Fedora_43.x86_64.rpm

#### Example for enabling a System Unit File

systemctl enable podman.socket
