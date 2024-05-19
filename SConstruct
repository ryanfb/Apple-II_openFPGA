import pfDevTools

# -- We need pf-dev-tools version 1.x.x but at least 1.0.9.
pfDevTools.requires('1.0.9')

env = pfDevTools.SConsEnvironment(PF_DOCKER_IMAGE='didiermalenfant/quartus:22.1-apple-silicon', PF_CORE_QSF_FILE='ap_core.qsf')
env.OpenFPGACore('src/config.toml')
