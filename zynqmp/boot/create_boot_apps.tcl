# Generate boot products for Xilinx ZCU102
#
# This script does the same thing that using the Xilinx SDK GUI does, but in a single command
# Generates:
# - First Stage Bootloader (fsbl)
# - Platform Management Unit Firmware (pmufw)
# - Device tree generated for your hardware platform (dts)
#
# Usage
#
# 1. Source the setup script found in the Xilinx SDK install directory, e.g.
#
#     source /opt/Xilinx/SDK/2018.3/settings64.sh
#
# 2. Source this Tcl script from a directory that contains a hardware description file (HDF)
#
#     xsct /path/to/create_boot_apps.tcl
#

set xilinx_version "2018.3"

set hwspec [glob *.hdf]
set hwproject [file rootname [file tail $hwspec]]

file mkdir build
file copy -force $hwspec build/

file delete -force build/device-tree-xlnx
exec -ignorestderr git clone https://github.com/Xilinx/device-tree-xlnx -q --branch xilinx-v${xilinx_version} build/device-tree-xlnx

setws build
repo -set build/device-tree-xlnx
createhw -name $hwproject -hwspec build/$hwspec
createapp -name fsbl -hwproject $hwproject -proc psu_cortexa53_0 -app {Zynq MP FSBL} -os standalone
configapp -app fsbl define-compiler-symbols FSBL_DEBUG_DETAILED
createapp -name pmufw -hwproject $hwproject -proc psu_pmu_0 -app {ZynqMP PMU Firmware} -os standalone
createbsp -name device_tree -hwproject $hwproject -proc psu_cortexa53_0 -os device_tree
configbsp -bsp device_tree periph_type_overrides "{BOARD zcu102-rev1.0}"
regenbsp -bsp device_tree
projects -build

# The device tree generator uses the #include syntax in the DTS files which
# requires preprocessing by a compiler (usually gcc), where as the /include/
# syntax is recognized natively by the dtc tool
foreach file [glob build/**/*.dts] {
    exec sed -i {s/^#include/\/include\//} $file
}

set bit_file [glob build/**/*.bit]
file copy -force $bit_file build/bitstream.bit

exit
