workspace(name = "pycross_image")

load("@pycross_image//bazel:repositories.bzl", "repositories")

repositories()

# -----------------------------------------

load(
    "@pycross_image//bazel:workspace0.bzl",
    "setup_aspect_bazel_lib",
    "setup_bazel_gazelle",
    "setup_bazel_skylib",
    "setup_rules_docker",
    "setup_rules_go",
    "setup_rules_oci",
    "setup_rules_python",
    "setup_zig_toolchains",
)

setup_zig_toolchains()

setup_rules_go()

setup_bazel_gazelle()

setup_bazel_skylib()

setup_rules_python()

setup_aspect_bazel_lib()

setup_rules_oci()

setup_rules_docker()

# -----------------------------------------

load(
    "@pycross_image//bazel:workspace1.bzl",
    "setup_docker_containers",
    "setup_oci_containers",
    "setup_rules_pycross",
)

setup_oci_containers()

setup_docker_containers()

setup_rules_pycross()

# -----------------------------------------

load(
    "@pycross_image//bazel:workspace2.bzl",
    "setup_pdm_deps",
)

setup_pdm_deps()

# -----------------------------------------

load(
    "@pycross_image//bazel:workspace3.bzl",
    "install_pdm_deps",
)

install_pdm_deps()
