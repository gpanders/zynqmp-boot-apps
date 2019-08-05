set hwspec [glob *.hdf]
set hwproject [file rootname [file tail $hwspec]]

file mkdir build
file copy -force $hwspec build/

set xilinx_version "master"
if { $::argc > 0 } {
    set xilinx_version "xilinx-v[lindex $::argv 0]"
}

file delete -force build/workspace
setws build/workspace

file delete -force build/device-tree-xlnx
exec -ignorestderr git clone -q --branch $xilinx_version https://github.com/Xilinx/device-tree-xlnx build/device-tree-xlnx
repo -set build/device-tree-xlnx

createhw -name $hwproject -hwspec build/$hwspec
createapp -name fsbl -hwproject $hwproject -proc psu_cortexa53_0 -app {Zynq MP FSBL} -os standalone
configapp -app fsbl define-compiler-symbols FSBL_DEBUG_DETAILED
createapp -name pmufw -hwproject $hwproject -proc psu_pmu_0 -app {ZynqMP PMU Firmware} -os standalone
createbsp -name device_tree -hwproject $hwproject -proc psu_cortexa53_0 -os device_tree
configbsp -bsp device_tree periph_type_overrides "{BOARD zcu102-rev1.0}"
regenbsp -bsp device_tree
projects -build

# Copy all output products to top level build directory
file delete -force build/device_tree
file copy -force build/workspace/device_tree build/
file copy -force build/workspace/fsbl/Debug/fsbl.elf build/
file copy -force build/workspace/pmufw/Debug/pmufw.elf build/
file copy -force [glob build/workspace/$hwproject/*.bit] build/bitstream.bit

exit
