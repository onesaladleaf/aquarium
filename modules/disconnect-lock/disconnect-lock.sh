#!/usr/bin/env bash
systemd-run --uid=1000 --gid=1000 --setenv=WAYLAND_DISPLAY="wayland-1" --setenv=XDG_RUNTIME_DIR="/run/user/1000" swaylock --color 1f1f28 --inside-color 1f1f28 --line-color 1f1f2
