.PHONY: all bootgen apps dtb clean install

all: bootgen dtb

bootgen: build/BOOT.bin

apps: build/fsbl.elf build/pmufw.elf

dtb: build/system.dtb

clean:
	rm -rf build/workspace
	rm -rf build/fsbl.elf
	rm -rf build/pmufw.elf
	rm -rf build/device_tree
	rm -rf build/device-tree-xlnx
	rm -rf build/system.dtb
	rm -rf build/BOOT.bin

install: bootgen dtb
	cp -f build/BOOT.bin $(INSTALL_DIR)
	cp -f build/system.dtb $(INSTALL_DIR)

build/BOOT.bin: build/fsbl.elf build/pmufw.elf build/u-boot.elf build/bl31.elf
	bootgen -image bootgen.bif -arch zynqmp -w on -o $@

build/fsbl.elf build/pmufw.elf build/device_tree/system-top.dts:
	xsct create_boot_apps.tcl $(VER)

build/system.dtb: build/device_tree/system-top.dts build/device_tree/*.dts[i]
	cpp -nostdinc -undef -D__DTS__ -x assembler-with-cpp -I $(<D) -o $<.tmp $<
	dtc -I dts -O dtb -o $@ $<.tmp

build/u-boot.elf:
	$(error Missing u-boot.elf. Build U-Boot separately and place the generated u-boot.elf file into the 'build' directory)

build/bl31.elf:
	$(error Missing bl31.elf. Build ATF separately and place the generated bl31.elf file into the 'build' directory)
