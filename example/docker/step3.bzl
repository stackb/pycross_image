load(
    "@rules_pycross//pycross:workspace.bzl",
    "lock_repo_model_pdm",
    "pycross_lock_repo",
)
load(
    "@pycross_toolchains//:defs.bzl",
    "environments",
)
load(
    "@io_bazel_rules_docker//container:pull.bzl",
    "container_pull",
)

def _setup_docker_containers():
    container_pull(
        name = "distroless_python3_debian12_container",
        # from 'crane manifest gcr.io/distroless/python3-debian12:latest'
        digest = "sha256:0078c63ba4e9bb13eef1576a183fc0bc3fd04fd3d5a9bad5ede1069bddca0ebd",
        registry = "gcr.io",
        repository = "distroless/python3-debian12",
        docker_client_config = "//:.dockerconfig.json",
    )

def _setup_pypi_deps():
    pycross_lock_repo(
        name = "pypi",
        lock_model = lock_repo_model_pdm(
            lock_file = "@//:pdm.lock",
            project_file = "@//:pyproject.toml",
        ),
        package_build_dependencies = {
            "grpclib": [
                "setuptools",
                "wheel",
            ],
        },
        target_environments = environments,
    )

step3 = struct(
    setup_docker_containers = _setup_docker_containers,
    setup_pypi_deps = _setup_pypi_deps,
)
