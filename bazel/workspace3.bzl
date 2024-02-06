load(
    "@poetry//:defs.bzl",
    "install_deps",
)

def setup_poetry_deps():
    install_deps()
