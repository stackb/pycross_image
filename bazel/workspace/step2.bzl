load(
    "@python//:defs.bzl",
    python_interpreter = "interpreter",
)
load(
    "@rules_pycross//pycross:repositories.bzl",
    "rules_pycross_dependencies",
)
load(
    "@rules_pycross//pycross:workspace.bzl",
    "pycross_register_for_python_toolchains",
)
load(
    "@io_bazel_rules_docker//container:pull.bzl",
    "container_pull",
)
load(
    "@rules_oci//oci:pull.bzl",
    "oci_pull",
)

def _setup_rules_pycross(
        pycross_toolchains_repo_name = "pycross_toolchains",
        glibc_version = "2.28"):
    rules_pycross_dependencies(
        python_interpreter_target = python_interpreter,
    )
    pycross_register_for_python_toolchains(
        name = pycross_toolchains_repo_name,
        glibc_version = glibc_version,
        python_toolchains_repo = "@python",
    )

def _setup_oci_containers():
    oci_pull(
        name = "distroless_base",
        digest = "sha256:ccaef5ee2f1850270d453fdf700a5392534f8d1a8ca2acda391fbb6a06b81c86",
        image = "gcr.io/distroless/base",
        platforms = [
            "linux/amd64",
            "linux/arm64",
        ],
    )

    oci_pull(
        name = "distroless_python3_debian12_oci",
        digest = "sha256:0078c63ba4e9bb13eef1576a183fc0bc3fd04fd3d5a9bad5ede1069bddca0ebd",
        image = "gcr.io/distroless/python3-debian12",
    )

def _setup_docker_containers():
    container_pull(
        name = "distroless_python3_debian12_container",
        # from 'crane manifest gcr.io/distroless/python3-debian12:latest'
        digest = "sha256:0078c63ba4e9bb13eef1576a183fc0bc3fd04fd3d5a9bad5ede1069bddca0ebd",
        registry = "gcr.io",
        repository = "distroless/python3-debian12",
        # docker_client_config = "@pycross_image//:.dockerconfig.json",
    )

step2 = struct(
    setup_rules_pycross = _setup_rules_pycross,
    setup_docker_containers = _setup_docker_containers,
    setup_oci_containers = _setup_oci_containers,
)
