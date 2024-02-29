"""
Wrapper macro to make three separate layers for python applications

based on: https://github.com/aspect-build/bazel-examples/blob/a25b6c0ba307545aff6c4b5feb4ae875d7d507f1/oci_python_image/py_layer.bzl
"""

load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_binary")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_tarball")
# load(":py_layers.bzl", "py_layers")

def _make_entrypoint(toolchain_config_setting_label, workdir, cmd):
    print("workdir:", workdir)
    label = Label(toolchain_config_setting_label)
    return "{workdir}/{cmd}.runfiles/{python_toolchains_workspace_name}_{python_toolchains_config_setting}/bin/python3".format(
        workdir = workdir,
        cmd = cmd,
        python_toolchains_workspace_name = label.workspace_name,
        python_toolchains_config_setting = label.name,
    )

def py_image(
        name,
        binary,
        base = "@distroless_python3_debian12",
        tars = [],
        config = "@python//:x86_64-unknown-linux-gnu",
        target_platform = "@pycross_image//platform:linux_x86_64",
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
        base: (Label) target label of the base image
        tars: (Label List) optional additional tars for the image
        config: (Label) target label for the python toolchains repo config setting that determines the python entrypoint name
        target_platform: (Label) target label for the image platform (for the platform_transition_binary rule)
        **kwargs: (Dict) additional argument for the oci_image rule
    """

    name_tar = name + ".tar"
    target = Label(binary)
    print("target:", target)
    cmd = target.name
    cross_binary = cmd + "_cross_binary"
    repo_tag = "%s/%s:latest" % (target.package, target.name)

    workdir = "/%s/%s/%s" % (target.package, target.name, cross_binary)
    entrypoint = _make_entrypoint(config, workdir, cmd)

    # layer_tars = py_layers(name, cross_binary)
    layer_tars = []

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
        base = base,
        **kwargs
    )

    oci_tarball(
        name = name_tar,
        image = name,
        repo_tags = [repo_tag],
    )
