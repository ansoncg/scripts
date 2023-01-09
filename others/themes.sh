#!/bin/bash

schema="org.gnome.desktop.interface"
gsettings set $schema gtk-theme 'Dracula'
gsettings set $schema icon-theme 'Dracula'
gsettings set $schema cursor-theme 'Dracula-cursors'
gsettings set $schema font-name 'FiraCode Nerd Font 10'

gsettings set org.gnome.desktop.wm.preferences theme "Dracula"
