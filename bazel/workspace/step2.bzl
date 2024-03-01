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

# from 'crane manifest gcr.io/distroless/python3-debian12:latest' circa Jan 2024
python3_debian12_image = struct(
    registry = "gcr.io",
    repository = "distroless/python3-debian12",
    digest = "sha256:0078c63ba4e9bb13eef1576a183fc0bc3fd04fd3d5a9bad5ede1069bddca0ebd",
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

def _setup_pycross_image_base_oci(**kwargs):
    digest = kwargs.pop("digest", python3_debian12_image.digest)
    image = kwargs.pop("image", "%s/%s" % (python3_debian12_image.registry, python3_debian12_image.repository))

    oci_pull(
        name = "pycross_image_base_oci",
        digest = digest,
        image = image,
        **kwargs
    )

def _setup_pycross_image_base_container(**kwargs):
    digest = kwargs.pop("digest", python3_debian12_image.digest)
    registry = kwargs.pop("image", python3_debian12_image.registry)
    repository = kwargs.pop("repository", python3_debian12_image.repository)

    container_pull(
        name = "pycross_image_base_container",
        digest = digest,
        # tag = "debug", # enable for debugging e.g 'docker run -it --entrypoint=sh bazel/bazel/tools/pdm:container'
        registry = registry,
        repository = repository,
        **kwargs
    )

step2 = struct(
    setup_rules_pycross = _setup_rules_pycross,
    setup_pycross_image_base_container = _setup_pycross_image_base_container,
    setup_pycross_image_base_oci = _setup_pycross_image_base_oci,
)
