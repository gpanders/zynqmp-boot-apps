.PHONY: bootgen apps dts clean install

bootgen: build/BOOT.bin

apps: build/fsbl/Debug/fsbl.elf build/pmufw/Debug/pmufw.elf

dts: build/system.dtb

build/BOOT.bin: build/fsbl/Debug/fsbl.elf build/pmufw/Debug/pmufw.elf build/u-boot.elf build/bl31.elf
	bootgen -image bootgen.bif -arch zynqmp -w on -o build/BOOT.bin


build/fsbl/Debug/fsbl.elf build/pmufw/Debug/pmufw.elf build/device_tree/system-top.dts:
	xsct create_boot_apps.tcl

build/system.dtb: build/device_tree/system-top.dts
	dtc -I dts -O dtb -o build/system.dtb $<

clean:
	rm -rf build/fsbl{,_bsp} build/pmufw{,_bsp} build/device_tree build/device-tree-xlnx build/system.dtb build/BOOT.bin

install:
	cp -f build/BOOT.bin $(INSTALL_DIR)
	cp -f build/system.dtb $(INSTALL_DIR)
