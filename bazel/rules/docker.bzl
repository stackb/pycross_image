load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_layer")
load(":support.bzl", "defaults", "py_layers", "pycross_binary")

def py_image(
        name,
        binary,
        base = "@pycross_image_base_container//image",
        layers = [],
        **kwargs):
    """
    py_image is a macro that instantiates an container_image from a py_binary rule

    Args:
        name: name for the image rule
        binary: target label of the py_binary rule
        base: target label of the base image
        layers: additional container_layer targets
        **kwargs: additional arguments for the pycross_binary and container_image rules
    """

    metadata = pycross_binary(
        binary,
        cross_name_prefix = kwargs.pop("cross_name_prefix", defaults.cross_name_prefix),
        python_config_setting = kwargs.pop("python_config_setting", defaults.python_config_setting),
        target_platform = kwargs.pop("target_platform", defaults.target_platform),
        image_tag = kwargs.pop("tag", defaults.cross_name_prefix),
        repo_tag = kwargs.pop("repo_tag", None),
    )

    tars = py_layers(name, metadata.cross_binary_name)

    for tar in tars:
        container_layer(
            name = tar + "_layer",
            tars = [tar],
        )

    container_image(
        name = name,
        base = base,
        layers = layers + [tar + "_layer" for tar in tars],
        entrypoint = metadata.entrypoint,
        cmd = metadata.cmd,
        workdir = metadata.workdir,
        tags = [metadata.repo_tag],
        **kwargs
    )
