"""
Wrapper macro to make three separate layers for python applications

based on: https://github.com/aspect-build/bazel-examples/blob/a25b6c0ba307545aff6c4b5feb4ae875d7d507f1/oci_python_image/py_layer.bzl
"""

load("@aspect_bazel_lib//lib:tar.bzl", "mtree_spec", "tar")

def py_layers(name, binary):
    """Create three layers for a py_binary target: interpreter, third-party dependencies, and application code.

    This allows a container image to have smaller uploads, since the application layer usually changes more
    than the other two.

    Args:
        name: prefix for generated targets, to ensure they are unique within the package
        binary: a py_binary target
    Returns:
        a list of labels for the layers, which are tar files
    """

    # Produce the manifest for a tar file of our py_binary, but don't tar it up yet, so we can split
    # into fine-grained layers for better docker performance.
    mtree_spec(
        name = name + ".mf",
        srcs = [binary],
    )

    # match *only* external repositories that have the string "python"
    # e.g. this will match
    #   `/hello_world/hello_world_bin.runfiles/rules_python~0.21.0~python~python3_9_aarch64-unknown-linux-gnu/bin/python3`
    # but not match
    #   `/hello_world/hello_world_bin.runfiles/_main/python_app`
    py_interpreter_regex = "\\.runfiles/.*python.*-.*"

    # match *only* external pip like repositories that contain the string "site-packages"
    site_packages_regex = "\\.runfiles/.*/site-packages/.*"

    native.genrule(
        name = name + ".interpreter_tar_manifest",
        srcs = [name + ".mf"],
        outs = [name + ".interpreter_tar_manifest.spec"],
        cmd = "grep '{}' $< >$@".format(py_interpreter_regex),
    )

    native.genrule(
        name = name + ".packages_tar_manifest",
        srcs = [name + ".mf"],
        outs = [name + ".packages_tar_manifest.spec"],
        cmd = "grep '{}' $< >$@".format(site_packages_regex),
    )

    # Any lines that didn't match one of the two grep above
    native.genrule(
        name = name + ".app_tar_manifest",
        srcs = [name + ".mf"],
        outs = [name + ".app_tar_manifest.spec"],
        cmd = "grep -v '{}' $< | grep -v '{}' >$@".format(site_packages_regex, py_interpreter_regex),
    )

    result = []
    for layer in ["interpreter", "packages", "app"]:
        layer_target = "{}.{}_layer".format(name, layer)
        result.append(layer_target)
        tar(
            name = layer_target,
            srcs = [binary],
            mtree = "{}.{}_tar_manifest".format(name, layer),
        )

    return result
