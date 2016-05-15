#!/bin/sh

set -e
: ${BITFILE=/boot/parallella.bit.bin}

sudo dd if=${BITFILE} of=/dev/xdevcfg
sudo modprobe epiphany
sudo systemctl start parallella-thermald@epiphany-mesh0.service
