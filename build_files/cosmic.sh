#!/bin/bash
set -ouex pipefail

# COSMIC is packaged in the official Fedora repos (F42+).
# Based on Jorge Castro's example: https://github.com/castrojo/bazzite-cosmic
# If the Fedora packages are ever missing/broken, fall back to the COPR and
# disable it afterwards so it does not stay enabled in the final image:
# dnf5 -y copr enable ryanabx/cosmic-epoch
dnf5 -y install @cosmic-desktop @cosmic-desktop-apps
# dnf5 -y copr disable ryanabx/cosmic-epoch

# SDDM stays the display manager; COSMIC is selectable as a session there,
# with Plasma remaining available as a fallback session.
# Optional: switch to COSMIC's greeter instead:
# systemctl disable sddm.service
# systemctl enable cosmic-greeter.service
