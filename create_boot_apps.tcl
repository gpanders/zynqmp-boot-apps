set hwspec [glob *.hdf]
set hwproject [file rootname [file tail $hwspec]]

file mkdir build
file copy -force $hwspec build/

set xilinx_version "master"
if { $::argc > 0 } {
    set xilinx_version "xilinx-v[lindex $::argv 0]"
}

file delete -force build/device-tree-xlnx
exec -ignorestderr git clone -q --branch $xilinx_version https://github.com/Xilinx/device-tree-xlnx build/device-tree-xlnx

file delete -force build/workspace

setws build/workspace
repo -set build/device-tree-xlnx
createhw -name $hwproject -hwspec build/$hwspec
createapp -name fsbl -hwproject $hwproject -proc psu_cortexa53_0 -app {Zynq MP FSBL} -os standalone
configapp -app fsbl define-compiler-symbols FSBL_DEBUG_DETAILED
createapp -name pmufw -hwproject $hwproject -proc psu_pmu_0 -app {ZynqMP PMU Firmware} -os standalone
createbsp -name device_tree -hwproject $hwproject -proc psu_cortexa53_0 -os device_tree
projects -build

# Copy all outputu products to top level build directory
file copy -force build/workspace/device_tree build/device_tree
file copy -force build/workspace/fsbl/Debug/fsbl.elf build/fsbl.elf
file copy -force build/workspace/pmufw/Debug/pmufw.elf build/pmufw.elf
file copy -force [glob build/workspace/$hwproject/*.bit] build/bitstream.bit

exit
