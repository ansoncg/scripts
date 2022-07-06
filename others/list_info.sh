#!/bin/bash

# Kernel
uname -a

# PCI
lspci -vvv

# USB
lsusb -vv

# CPU
lscpu 

# Mounts
lsblk

# Hardware
lshw

# Bios
dmidecode
