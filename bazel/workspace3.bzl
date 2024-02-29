"workspace loading - phase 4"

load(
    "@pypi_deps_for_pdm//:defs.bzl",
    "install_deps",
)

def install_pdm_deps():
    install_deps()
