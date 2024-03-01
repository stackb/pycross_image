load("@pypi//:defs.bzl", "install_deps")

def _install_pypi_deps():
    install_deps()

step4 = struct(
    install_pypi_deps = _install_pypi_deps,
)
