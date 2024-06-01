# Apple-II_openFPGA

[Apple-II_MiSTer](https://github.com/MiSTer-devel/Apple-II_MiSTer) ported to openFPGA (Analogue Pocket).

Based off [open-fpga/core-template](https://github.com/open-fpga/core-template).

Build with e.g.:

    docker run --platform linux/amd64 -t --rm -v $(pwd)/src/fpga:/build didiermalenfant/quartus:22.1-apple-silicon quartus_sh --flow compile ap_core

Then use [pf-dev-tools](https://pypi.org/project/pf-dev-tools/) (`pip install pf-dev-tools==1.0.9`) to package a zip:

    pf build src/config.toml src/fpga/output_files/ap_core.rbf build

A zip should be built in `build/`, which you can copy to your Analogue Pocket.

## Notes

 * [`src/fpga/rtl`](https://github.com/ryanfb/Apple-II_openFPGA/tree/main/src/fpga/rtl) = [Apple-II_MiSTer `rtl`](https://github.com/MiSTer-devel/Apple-II_MiSTer/tree/master/rtl). The goal is not to touch upstream MiSTer RTL and just wire a new openFPGA system interface into it. If this seems feasible, I may convert the `rtl` directory to a git submodule.
 * Instead of using [Apple-II_MiSTer's (MiSTer-specific) `module emu` in `Apple-II.sv`](https://github.com/MiSTer-devel/Apple-II_MiSTer/blob/master/Apple-II.sv), we declare [a new (openFPGA-specific) `module MAIN_APPLE2` in `src/fpga/core/openfpga_top/main.sv`](https://github.com/ryanfb/Apple-II_openFPGA/blob/main/src/fpga/core/openfpga_top/main.sv), which we then wire in to the RTL `apple2_top` at [`rtl/apple2_top.vhd`](https://github.com/MiSTer-devel/Apple-II_MiSTer/blob/master/rtl/apple2_top.vhd). This `MAIN_APPLE2` module interface is then used from [the main openFPGA core top in `src/fpga/core/core_top.v`](https://github.com/ryanfb/Apple-II_openFPGA/blob/main/src/fpga/core/core_top.v).
