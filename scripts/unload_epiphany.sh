#!/bin/sh

set -e

sudo systemctl stop parallella-thermald@epiphany-mesh0.service
sudo rmmod epiphany
