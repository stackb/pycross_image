load("@//bazel:repositories.bzl", "repositories")

repositories()

# -----------------------------------------

load(
    "@//bazel:workspace0.bzl",
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
    "@//bazel:workspace1.bzl",
    "setup_containers",
    "setup_rules_pycross",
)

setup_containers()

setup_rules_pycross()

# -----------------------------------------

load(
    "@//bazel:workspace2.bzl",
    "setup_poetry",
)

setup_poetry()

# -----------------------------------------

load(
    "@//bazel:workspace3.bzl",
    "setup_poetry_deps",
)

setup_poetry_deps()
