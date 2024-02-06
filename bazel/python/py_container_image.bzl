"py_image macro"

load("//bazel_tools:container.bzl", "container_image", "container_layer")
load(":py_image_layer.bzl", "py_image_layer")

def py_image(name, binary, package, base, root = "/app", **kwargs):
    """container_image macro for a py_binary using py_image_layer.

    Args:
        name: [String] The name of the container_image rule.  Also used as a name prefix for supporting rules declared within this one.
        binary: [String] The label name of the binary target to wrap (for py_image_layer.binary)
        base: for the container_image.base attribute
        package: [String] the label package of the rule.  Needed for the entrypoint.
        root: [String] root directory for the app
        **kwargs: additional kwargs for the container_image rule
    """
    layers_name = name + "_layers"
    app_tar_name = name + "_app_tar"
    app_layer_name = name + "_app_layer"
    site_packages_tar_name = name + "_site_packages_tar"
    site_packages_layer_name = name + "_site_packages_layer"
    python3_tar_name = name + "_python3_tar"
    python3_layer_name = name + "_python3_layer"

    # py_image_layer collects all the data/runfiles from the given py_binary (or
    # actually any DefaultInfo-providing label) and partitions thise files into
    # site_packages/ and non-site_packages files.  These are placed in the
    # "site_packages" and "app" output groups respectively.
    py_image_layer(
        name = layers_name,
        binary = binary,
        root = root,
        visibility = ["//visibility:__pkg__"],
    )

    native.filegroup(
        name = app_tar_name,
        srcs = [layers_name],
        output_group = "app",
    )
    native.filegroup(
        name = site_packages_tar_name,
        srcs = [layers_name],
        output_group = "site_packages",
    )
    native.filegroup(
        name = python3_tar_name,
        srcs = [layers_name],
        output_group = "python3",
    )

    container_layer(
        name = app_layer_name,
        tars = [app_tar_name],
    )
    container_layer(
        name = site_packages_layer_name,
        tars = [site_packages_tar_name],
    )
    container_layer(
        name = python3_layer_name,
        tars = [python3_tar_name],
    )

    # The default image is the linux amd version. If user requested arm, select
    # on the config setting. If user requested a specific base, override and use
    # that.

    container_image(
        name = name,
        base = base,
        layers = [
            app_layer_name,
            site_packages_layer_name,
            python3_layer_name,
        ],
        workdir = "%s/%s/%s.runfiles/unity" % (root, package, binary),
        # entrypoint = ["%s/%s" % (package, binary)],
        cmd = ["%s/%s" % (package, binary)],
        **kwargs
    )
