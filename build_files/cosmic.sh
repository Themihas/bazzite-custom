#!/bin/bash
set -ouex pipefail

# COSMIC is packaged in the official Fedora repos (F42+).
# Based on Jorge Castro's example: https://github.com/castrojo/bazzite-cosmic
# If the Fedora packages are ever missing/broken, fall back to the COPR and
# disable it afterwards so it does not stay enabled in the final image:
# dnf5 -y copr enable ryanabx/cosmic-epoch
dnf5 -y install @cosmic-desktop @cosmic-desktop-apps
# dnf5 -y copr disable ryanabx/cosmic-epoch

# Use COSMIC's greeter instead of Bazzite's Plasma Login Manager. With plasmalogin,
# its kwin_wayland greeter still holds DRM master when cosmic-comp starts, leaving
# COSMIC in "unprivileged mode" and nearly unusable. Plasma remains selectable as
# a fallback session in cosmic-greeter.
systemctl disable plasmalogin.service
systemctl enable cosmic-greeter.service

# xwaylandvideobridge is a KDE helper whose autostart entry lacks OnlyShowIn, so it
# shows up as an empty, unclosable window under COSMIC. Restrict it to Plasma.
echo "OnlyShowIn=KDE;" >> /etc/xdg/autostart/org.kde.xwaylandvideobridge.desktop
