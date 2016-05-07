About
-----------

This folder contains build script to cross compile Xilinx version of the Linux
kernel in a configuration suitable for experimenting with FPGA on parallella
board.

This combines Xilinx kernel release 2016.1 with Epiphany driver from Adapteva Linux release 2016.3.


Why
-------

Default Linux kernel shipped with Parallella board no longer supports FPGA
re-configuration (no /dev/xdevcfg). That driver is not just not compiled in, it
is absent from the source code, as it wasn't mainlined yet. Rather than porting
Xilinx drivers over to Adapteva kernel it was easier to port Epiphany driver
over to Xilinx kernel.

How To Use
--------------

Make sure you have right tools installed (Assuming modern enough Ubuntu)

```
   sudo apt update
   sudo apt install \
      build-essential \
      gcc-arm-linux-gnueabihf \
      u-boot-tools \
      bc
```

Run `./build.sh` this will download linux sources, apply patches and cross-compile kernel.
