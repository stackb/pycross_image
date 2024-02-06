load(
    "@rules_pycross//pycross:workspace.bzl",
    "lock_repo_model_poetry",
    "pycross_lock_repo",
)
load(
    "@pycross_toolchains//:defs.bzl",
    "environments",
)

def setup_poetry():
    lock_model = lock_repo_model_poetry(
        lock_file = "@//:poetry.lock",
        project_file = "@//:pyproject.toml",
    )

    pycross_lock_repo(
        name = "poetry",
        lock_model = lock_model,
        target_environments = environments,
    )
