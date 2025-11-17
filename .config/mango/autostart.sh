#! /bin/bash

set +e

dbus-update-activation-environment --systemd WAYLAND_DISPLAY
