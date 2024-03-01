load(
    "@rules_pycross//pycross:workspace.bzl",
    "lock_repo_model_pdm",
    "pycross_lock_repo",
)
load(
    "@pycross_toolchains//:defs.bzl",
    "environments",
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
    setup_pypi_deps = _setup_pypi_deps,
)
