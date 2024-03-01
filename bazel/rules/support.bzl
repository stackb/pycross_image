"""
Support functions
"""

load("@aspect_bazel_lib//lib:tar.bzl", "mtree_spec", "tar")
load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_binary")

defaults = struct(
    python_config_setting = "@python//:x86_64-unknown-linux-gnu",
    target_platform = "@pycross_image//bazel/platforms:linux_x86_64",
    cross_name_prefix = "x",
    image_tag = "latest",
)

def py_layers(name, binary):
    """Create three layers for a py_binary target: interpreter, third-party dependencies, and application code.

    based on: https://github.com/aspect-build/bazel-examples/blob/a25b6c0ba307545aff6c4b5feb4ae875d7d507f1/oci_python_image/py_layer.bzl

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

def _make_entrypoint(toolchain_config_setting_label, workdir, cmd):
    label = Label(toolchain_config_setting_label)
    return "{workdir}/{cmd}.runfiles/{python_toolchains_workspace_name}_{python_toolchains_config_setting}/bin/python3".format(
        workdir = workdir,
        cmd = cmd,
        python_toolchains_workspace_name = label.workspace_name,
        python_toolchains_config_setting = label.name,
    )

def pycross_binary(
        binary,
        name = None,
        cross_name_prefix = defaults.cross_name_prefix,
        python_config_setting = defaults.python_config_setting,
        target_platform = defaults.target_platform,
        image_tag = defaults.image_tag,
        repo_tag = None):
    """pycross_binary declares a transitioned py_binary and prepares the image metadata.

    Args:
        name: name of the cross_binary, will be
        binary: a Label to a py_binary to be packaged
        cross_name_prefix: a prefix that can be used to make the platform_transition_binary name more unique.
        python_config_setting: optional label to the python interpreter config_setting rule.
        target_platform: Label string: the platform to transition to
        image_tag: a tag for the image, defaults to "latest"
        repo_tag: repo_tag for the image, defaults to '{package_name}/{label_name}/{tag}'
    Returns:
        a struct for the image metadata.
    """

    # Label: the label of the py_binary to be packaged
    target = native.package_relative_label(binary)

    # string: a label name for the platform_transition_binary. use a prefix such
    # that if a package has both an oci and docker py_image, the
    # platform_transition_binary names don't collide.
    name = cross_name_prefix + target.name

    # string: the workdir.  The entrypoint will be in the directory where the
    # platform_transition_binary lives
    workdir = "/%s/%s" % (target.package, name)

    # string: the (repo_)tag of the container.  Can be overridden by user.
    if not repo_tag:
        repo_tag = "%s/%s:%s" % (target.package, target.name, image_tag)

    # string: the entrypoint. See structure test for details.
    entrypoint = _make_entrypoint(python_config_setting, workdir, target.name)

    platform_transition_binary(
        name = name,
        binary = binary,
        target_platform = target_platform,
    )

    return struct(
        cross_binary_name = name,
        workdir = workdir,
        entrypoint = [entrypoint],
        cmd = [target.name],
        repo_tag = repo_tag,
    )
