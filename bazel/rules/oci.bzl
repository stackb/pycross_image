load(":support.bzl", "defaults", "py_layers", "pycross_binary")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_tarball")

def py_image(
        name,
        binary,
        base = "@pycross_image_base_oci",
        layers = [],
        **kwargs):
    """
    py_image is a macro that instantiates an oci_image from a py_binary rule

    Args:
        name: name for the image rule
        binary: target label of the py_binary rule
        base: target label of the base image
        layers: additional layer tarballs
        **kwargs: additional arguments for the pycross_binary and oci_image rules
    """
    metadata = pycross_binary(
        binary,
        cross_name_prefix = kwargs.pop("cross_name_prefix", "y"),
        python_config_setting = kwargs.pop("python_config_setting", defaults.python_config_setting),
        target_platform = kwargs.pop("target_platform", defaults.target_platform),
        image_tag = kwargs.pop("tag", defaults.cross_name_prefix),
        repo_tag = kwargs.pop("repo_tag", None),
    )

    tars = py_layers(name, metadata.cross_binary_name)

    oci_image(
        name = name,
        base = base,
        tars = layers + tars,
        workdir = metadata.workdir,
        entrypoint = metadata.entrypoint,
        cmd = metadata.cmd,
        **kwargs
    )

    oci_tarball(
        name = name + ".tar",
        image = name,
        repo_tags = [metadata.repo_tag],
    )
