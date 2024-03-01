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
load("@pycross_image//bazel/workspace:step2.bzl", "python3_debian12_image")

def _setup_container_base_image(**kwargs):
    digest = kwargs.pop("digest", python3_debian12_image.digest)
    registry = kwargs.pop("image", python3_debian12_image.registry)
    repository = kwargs.pop("repository", python3_debian12_image.repository)

    container_pull(
        name = "distroless_python3_debian12_container",
        digest = digest,
        registry = registry,
        repository = repository,
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
    setup_container_base_image = _setup_container_base_image,
    setup_pypi_deps = _setup_pypi_deps,
)
