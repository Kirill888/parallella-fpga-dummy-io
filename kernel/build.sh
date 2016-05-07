#!/bin/bash

: ${LINUX_TGZ=xilinx-v2016.1.tar.gz}
: ${LINUX_URL="https://github.com/Xilinx/linux-xlnx/archive/${LINUX_TGZ}"}
: ${B=$(pwd)/B}
: ${R=$(pwd)/ROOT}
: ${L=$(pwd)/linux-xlnx-xilinx-v2016.1}
: ${CROSS=arm-linux-gnueabihf-}

mk="make -C $L O=$B LOADADDR=0x8000 ARCH=arm CROSS_COMPILE=$CROSS"

fetch_linux () {
  echo "Will download from: " $LINUX_URL
  echo "Waiting for 5 seconds, use Ctrl-C to abort"
  sleep 5
  wget $LINUX_URL
  echo "  done"
}

prep_linux_dir () {
   echo "Extracting: $LINUX_TGZ"
   tar xzf $LINUX_TGZ
   echo "  done"
}

apply_patches () {
   for p in "*.patch"; do
      echo $p
      cat $p | patch -d "$L" -p1
   done
}

build_linux () {
   $mk parallella_defconfig
   $mk -j2
   $mk uImage
   mkdir -p $R/boot
   cp $B/arch/arm/boot/uImage $R/boot/uImage-4.4.xlnx

   $mk modules_install INSTALL_MOD_PATH=$R
   $mk headers_install INSTALL_HDR_PATH=$R/usr/src/linux-headers-4.4.xlnx/
}

cat <<EOL
  Linux Sources : $L
  Build folder  : $B
  Install Folder: $R
EOL
sleep 2

if [ ! -d $L ]; then
     if [ ! -f $LINUX_TGZ ]; then
         fetch_linux
     fi
     prep_linux_dir
     apply_patches
fi

build_linux
echo "Look here: $R"

