"""
Wrapper macro to make three separate layers for python applications

based on: https://github.com/aspect-build/bazel-examples/blob/a25b6c0ba307545aff6c4b5feb4ae875d7d507f1/oci_python_image/py_layer.bzl
"""

load("@aspect_bazel_lib//lib:tar.bzl", "mtree_spec", "tar")
load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_binary")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_tarball")
load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_layer")

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

    # Produce layers in this order, as the app changes most often
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

def pycross_oci_image(
        name,
        binary,
        tars = [],
        config = "@python//:x86_64-unknown-linux-gnu",
        target_platform = "@//bazel/python:linux_x86_64",
        **kwargs):
    """
    pycross_oci_image is a macro that instantiates an oci_image from a py_binary rule

    Given a pycross_oci_image rule `//my:image` wrapping a py_binary rule `//my:app`, the following targets are defined:

    | Kind                            | Label                        | Description                                              |
    |---------------------------------|------------------------------|----------------------------------------------------------|
    | oci_image rule                  | //my:image                   | The target container image                               |
    | oci_tarball rule                | //my:image.tar               | Tarball rule that can be `bazel run` to `docker load` it |
    | tar rule                        | //my:image.app_layer         | Image layer for the application code                     |
    | tar rule                        | //my:image.packages_layer    | Image layer for site-packages                            |
    | tar rule                        | //my:image.interpreter_layer | Image layer for the python3 interpreter                  |
    | platform_transition_binary rule | //my:xapp                    | The transitioned "cross" py_binary                       |
    | py_binary rule                  | //my:app                     | The source py_binary app                                 |

    `docker inspect` yields the following (subset):

    ```json
    [
        {
            "RepoTags": [
                "my/app:latest",
            ],
            "Config": {
                "Env": [
                    "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                    "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt",
                    "LANG=C.UTF-8"
                ],
                "Cmd": [
                    "app"
                ],
                "WorkingDir": "/my/xapp",
                "Entrypoint": [
                    "/my/xapp/app.runfiles/python_x86_64-unknown-linux-gnu/bin/python3"
                ],
            },
            "Architecture": "amd64",
            "Os": "linux"
        }
    ]
    ```

    Args:
        name: (String) name for the oci_image rule
        binary: (Label) target label of the py_binary rule
        tars: (Label List) optional additional tars for the image
        config: (Label) target label for the python toolchains repo config setting that determines the python entrypoint name
        target_platform: (Label) target label for the image platform (for the platform_transition_binary rule)
        **kwargs: (Dict) additional argument for the oci_image rule
    """

    name_tar = name + ".tar"
    target = Label(binary)
    cmd = target.name
    cross_binary = "x" + cmd
    repo_tag = "%s/%s:latest" % (target.package, target.name)
    workdir = "/%s/%s/%s" % (target.package, target.name, cross_binary)
    entrypoint = _make_entrypoint(config, workdir, cmd)
    layer_tars = py_layers(name, cross_binary)

    platform_transition_binary(
        name = cross_binary,
        binary = binary,
        target_platform = target_platform,
    )

    oci_image(
        name = name,
        tars = tars + layer_tars,
        workdir = workdir,
        entrypoint = [entrypoint],
        cmd = [cmd],
        **kwargs
    )

    oci_tarball(
        name = name_tar,
        image = name,
        repo_tags = [repo_tag],
    )

    for tar in layer_tars:
        container_layer(
            name = tar + "_layer",
            tars = [tar],
        )

    container_image(
        name = name + "_container",
        base = "@python3-debian12//image",
        layers = [tar + "_layer" for tar in layer_tars],
        workdir = workdir,
        entrypoint = [entrypoint],
        cmd = [cmd],
    )
