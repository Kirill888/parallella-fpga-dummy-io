CFLAGS=-std=c99 -Wall -g

all: uio_mult_test


uio_mult_test: uio_mult_test.c
	$(CC) $(CFLAGS) $< -o $@


#Compiled dts to dtb
devicetree.dtb: devicetree.dts pl.dtsi
	dtc -I dts -O dtb $< -o $@

#Grab current device tree and save it to system.dts
fetch_dts:
	dtc -I fs -O dts /proc/device-tree -o system.dts

clean:
	rm -f devicetree.dtb uio_mult_test

.PHONY: all clean fetch_dts
