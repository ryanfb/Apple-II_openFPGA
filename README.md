# Apple-II_openFPGA

[Apple-II_MiSTer](https://github.com/MiSTer-devel/Apple-II_MiSTer) ported to openFPGA (Analogue Pocket).

Based off [open-fpga/core-template](https://github.com/open-fpga/core-template).

Buid with e.g. (from `src/fpga`):

    docker run --platform linux/amd64 -t --rm -v $(pwd):/build didiermalenfant/quartus:22.1-apple-silicon quartus_sh --flow compile ap_core

Then from the top-level directory, use [pf-dev-tools](https://pypi.org/project/pf-dev-tools/):

    pf build src/config.toml src/fpga/output_files/ap_core.rbf build

## Hierarchy

 * [`src/fpga/rtl`](https://github.com/ryanfb/Apple-II_openFPGA/tree/main/src/fpga/rtl) = [Apple-II_MiSter `rtl`](https://github.com/MiSTer-devel/Apple-II_MiSTer/tree/master/rtl)
