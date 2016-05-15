CFLAGS=-std=c99 -Wall -Wextra -g

all: uio_mult_test


uio_mult_test: uio_mult_test.c
	$(CC) $(CFLAGS) $< -o $@


#Compiled dts to dtb
devicetree.dtb: devicetree.dts custom.dtsi
	dtc -I dts -O dtb $< -o $@

#Grab current device tree and save it to devicetree.dts
fetch_dts:
	dtc -I fs -O dts /proc/device-tree -o devicetree.dts
  echo '/include/ "custom.dtsi"; ' >> devicetree.dts

clean:
	rm -f devicetree.dtb uio_mult_test

.PHONY: all clean fetch_dts
