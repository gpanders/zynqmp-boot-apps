# Zynq MPSoC Boot Apps

Generate and install boot apps for the Zynq MPSoC device.

The scripts in this directory generate the following products:

- First Stage Bootloader (fsbl)
- Platform Management Unit Firmware (pmufw)
- Device tree blob (system.dtb)
- BOOT.bin file

You can think of this tool as a much lighter and less ~~bloated~~ feature-rich
version of PetaLinux. This tool is not meant to hold your hand and do everything
for you the way PetaLinux does, but rather enables you to use the command line
to do many of the steps typically done in the Xilinx SDK GUI.

## Prerequisites

Before using this tool you must first have created your hardware description
file in Vivado. This is done by creating a block design in Vivado with the Zynq
IP and selecting `File` > `Export Hardware` after compiling the bitstream. Make
sure you check the "Include bitstream" box. Once you have generated your
hardware description file, you can copy it into this directory.

In order to generate the BOOT.bin file you must also have built [U-Boot] and the
[ARM Trusted Firmware (ATF)] separately. These are not included in this
repository because of their size and because they are often tailored for
individual needs.  Once you have built U-Boot and ATF, copy the `u-boot.elf` and
`bl31.elf` files into this directory's `build` directory (you can create it if
it does not already exist).

## Usage

Simply drop your hardware description file (.hdf) into this directory and run

    $ make

You can set the version of the device tree generator to be used with the `VER`
variable:

    $ make VER=2018.3

It is recommended to use the same version as the version of Vivado you used to
create your design.

## Install to SD card

To install the output products to your SD card's boot partition, mount the
partition to a location on your host computer (e.g. `/media/sd/boot`) and run

    $ sudo make INSTALL_DIR=/media/sd/boot install

replacing `/media/sd/boot` with your actual mount point.

[U-Boot]: https://github.com/Xilinx/u-boot-xlnx
[ARM Trusted Firmware (ATF)]: https://github.com/Xilinx/arm-trusted-firmware.git

## Example

Below is an example of using this tool from start to finish with a design
created in Vivado 2018.3. **This is an example and file names and invocations
may change for your own needs**.

Start in your home directory.
```console
$ cd ~
```

Clone all required repositories.
```console
$ git clone https://github.com/Xilinx/u-boot-xlnx
$ git clone https://github.com/Xilinx/arm-trusted-firmware
$ git clone https://github.com/gpanders/zynqmp-boot-apps
```

Source the setup script provided with your SDK installation.
```console
$ source /opt/Xilinx/SDK/2018.3/settings64.sh
$ export CROSS_COMPILE="aarch64-linux-gnu-"
```

Build U-Boot. Be sure to checkout the tag corresponding to your version of
Vivado.
```console
$ cd ~/u-boot-xlnx
$ git checkout tags/xilinx-v2018.3
$ make xilinx_zynqmp_zcu102_rev1_0_defconfig
$ make -j8
```

Build the ARM Trusted Firmware. Again, checkout the correct tag.
```console
$ cd ~/arm-trusted-firmware
$ git checkout tags/xilinx-v2018.3
$ make PLAT=zynqmp -j8 all
```

Navigate to this repository and copy all required files.
```console
$ cd ~/zynqmp-boot-apps
$ cp /path/to/hdf_file.hdf .
$ mkdir build
$ cp ~/u-boot-xlnx/u-boot.elf ~/arm-trusted-firmware/build/zynqmp/release/bl31/bl31.elf build/
```

Mount your SD card's boot partition.
```console
$ sudo mkdir -p /media/sd/boot
$ sudo mount /dev/sdc1 /media/sd/boot
```

Make and install the boot files.
```console
$ make VER=2018.3
$ sudo make INSTALL_DIR=/media/sd/boot install
```
