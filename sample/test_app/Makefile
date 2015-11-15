CFLAGS=-std=c99 -Wall -g

all: devicetree.dtb uio_mult_test


devicetree.dtb: devicetree.dts pl.dtsi
	dtc -I dts -O dtb $< -o $@

uio_mult_test: uio_mult_test.c
	$(CC) $(CFLAGS) $< -o $@

fetch_dts:
	dtc -I fs -O dts /proc/device-tree -o system.dts

clean:
	rm -f devicetree.dtb uio_mult_test

.PHONY: all clean fetch_dts
