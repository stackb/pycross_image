load(
    "@rules_python//python:repositories.bzl",
    "py_repositories",
    "python_register_toolchains",
)
load(
    "@hermetic_cc_toolchain//toolchain:defs.bzl",
    zig_toolchains = "toolchains",
)
load(
    "@io_bazel_rules_docker//toolchains/docker:toolchain.bzl",
    docker_toolchain_configure = "toolchain_configure",
)
load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)
load(
    "@io_bazel_rules_go//go:deps.bzl",
    "go_register_toolchains",
    "go_rules_dependencies",
)
load(
    "@bazel_gazelle//:deps.bzl",
    "gazelle_dependencies",
)
load(
    "@io_bazel_rules_docker//repositories:deps.bzl",
    container_deps = "deps",
)
load(
    "@rules_oci//oci:dependencies.bzl",
    "rules_oci_dependencies",
)
load(
    "@rules_oci//oci:repositories.bzl",
    "LATEST_CRANE_VERSION",
    "oci_register_toolchains",
)
load(
    "@bazel_skylib//:workspace.bzl",
    "bazel_skylib_workspace",
)
load(
    "@aspect_bazel_lib//lib:repositories.bzl",
    "aspect_bazel_lib_dependencies",
    "aspect_bazel_lib_register_toolchains",
)

def _setup_zig_toolchains():
    "workspace chunk to declares and registers zig toolchains"
    zig_toolchains()
    native.register_toolchains(
        "@zig_sdk//toolchain:linux_amd64_gnu.2.28",
        "@zig_sdk//toolchain:linux_arm64_gnu.2.28",
        "@zig_sdk//toolchain:darwin_amd64",
        "@zig_sdk//toolchain:darwin_arm64",
    )

def _setup_rules_python(name = "python", python_version = "3.10.11"):
    py_repositories()
    python_register_toolchains(
        name = name,
        # NOTE: available versions are listed in @rules_python//python:versions.bzl.
        python_version = python_version,
    )

def _setup_rules_go(go_version = "1.20.12"):
    go_rules_dependencies()
    go_register_toolchains(go_version = go_version)

def _setup_rules_docker():
    if False:
        docker_toolchain_configure(
            name = "docker_config",
            client_config = "@pycross_image//:.dockerconfig.json",
        )
    container_repositories()
    container_deps()

def _setup_bazel_gazelle():
    gazelle_dependencies()

def _setup_bazel_skylib():
    bazel_skylib_workspace()

def _setup_aspect_bazel_lib():
    aspect_bazel_lib_dependencies()
    aspect_bazel_lib_register_toolchains()

def _setup_rules_oci():
    rules_oci_dependencies()
    oci_register_toolchains(
        name = "oci",
        crane_version = LATEST_CRANE_VERSION,
    )

step1 = struct(
    setup_aspect_bazel_lib = _setup_aspect_bazel_lib,
    setup_bazel_gazelle = _setup_bazel_gazelle,
    setup_bazel_skylib = _setup_bazel_skylib,
    setup_rules_docker = _setup_rules_docker,
    setup_rules_go = _setup_rules_go,
    setup_rules_oci = _setup_rules_oci,
    setup_rules_python = _setup_rules_python,
    setup_zig_toolchains = _setup_zig_toolchains,
)
