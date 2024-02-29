load("@pypi_deps_for_pdm//:defs.bzl", "install_deps")

def _install_pypi_deps_for_pdm():
    install_deps()

step4 = struct(
    install_pypi_deps_for_pdm = _install_pypi_deps_for_pdm,
)
