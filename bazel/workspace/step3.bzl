load(
    "@rules_pycross//pycross:workspace.bzl",
    "lock_repo_model_pdm",
    "pycross_lock_repo",
)
load(
    "@pycross_toolchains//:defs.bzl",
    "environments",
)

def _setup_pypi_deps_for_pdm(
        name = "pypi_deps_for_pdm",
        lock_file = "@//:pdm.lock",
        project_file = "@//:pyproject.toml"):
    pycross_lock_repo(
        name = name,
        lock_model = lock_repo_model_pdm(
            lock_file = lock_file,
            project_file = project_file,
        ),
        target_environments = environments,
    )

step3 = struct(
    setup_pypi_deps_for_pdm = _setup_pypi_deps_for_pdm,
)
