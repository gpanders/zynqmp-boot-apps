# Zynq MPSoC Boot Apps

Generate and install boot apps for the Zynq MPSoC device.

The scripts in this directory generate the following products:
- First Stage Bootloader (fsbl)
- Platform Management Unit Firmware (pmufw)
- Device tree blob
- BOOT.bin file

## Prerequisites

In order to generate the BOOT.bin file you must also have built [U-Boot] and the
[ARM Trusted Firmware (ATF)] separately. These are not included in this repository
because of their size and because they are often tailored for individual needs.
Once you have built U-Boot and ATF, copy the `u-boot.elf` and `bl31.elf` files
into this directory's `build` directory (you can create it if it does not
already exist).

## Usage

Simply drop your hardware description file (.hdf) into this directory and run

    $ make

## Install to SD card

To install the output products to your SD card's boot partition, mount the
partition to a location on your host computer (e.g. `/media/sd/boot`) and run

    $ sudo make INSTALL_DIR=/media/sd/boot install

replacing `/media/sd/boot` with your actual mount point.

[U-Boot]: https://github.com/Xilinx/u-boot-xlnx
[ARM Trusted Firmware (ATF)]: https://github.com/Xilinx/arm-trusted-firmware.git
