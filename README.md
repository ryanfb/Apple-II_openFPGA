# Apple-II_openFPGA

[Apple-II_MiSTer](https://github.com/MiSTer-devel/Apple-II_MiSTer) ported to openFPGA (Analogue Pocket).

Based off [open-fpga/core-template](https://github.com/open-fpga/core-template).

Build with e.g.:

    docker run --platform linux/amd64 -t --rm -v $(pwd)/src/fpga:/build didiermalenfant/quartus:22.1-apple-silicon quartus_sh --flow compile ap_core

Then use [pf-dev-tools](https://pypi.org/project/pf-dev-tools/) (`pip install pf-dev-tools==1.0.9`) to package a zip:

    pf build src/config.toml src/fpga/output_files/ap_core.rbf build

A zip should be built in `build/`, which you can copy to your Analogue Pocket.

## Notes

 * [`src/fpga/rtl`](https://github.com/ryanfb/Apple-II_openFPGA/tree/main/src/fpga/rtl) = [Apple-II_MiSter `rtl`](https://github.com/MiSTer-devel/Apple-II_MiSTer/tree/master/rtl). The goal is not to touch upstream MiSTer RTL and just wire a new openFPGA system interface into it. If this seems feasible, I may convert this to a git submodule.
