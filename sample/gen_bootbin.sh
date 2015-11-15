#!/bin/sh


if hash bootgen 2> /dev/null ; then
    echo ''
else
    cat <<EOF
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! No Vivado installation found
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  Please source appropriate 'settings' shell file for your installation

  Example:
     source /opt/Xilinx/Vivado/2015.3/settings64.sh

  Sourced it already? Then maybe you didn't install SDK, make
  sure to install SDK, it includes bootgen utility we need.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
EOF

    exit 1
fi

if [ ! -f parallella.bit ]; then
    cat <<EOF
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! File: parallella.bit not found in this folder
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Options are:

1. Export bistream file into this folder and name it parallella.bit
OR
2. Create a symlink to generated file inside the project

   For example like this:
     project_name=my_mult_test ln -s \${project_name}/\${project_name}.runs/impl_1/top.bit parallela.bit

EOF

    exit 1
fi


bootgen -w -image top.bif -split bin
rm top.bin

echo "Generated parallella.bit.bin"
echo " Now copy it to SD card and boot your board"
