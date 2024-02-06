"""Rules for creating container image layers from py_binary targets

For example, this py_image_layer target outputs `site_packages.tar` and `app.tar` with `/app` prefix.

```starlark
load("@aspect_rules_js//js:defs.bzl", "py_image_layer")

py_image_layer(
    name = "layers",
    binary = "//label/to:py_binary",
    root = "/app",
)
```
"""

load("@aspect_bazel_lib//lib:paths.bzl", "to_rlocation_path")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@aspect_bazel_lib//lib:utils.bzl", "is_bazel_6_or_greater")

_DOC = """Create container image layers from py_binary targets.

By design, py_image_layer doesn't have any preference over which rule assembles the container image. 
This means the downstream rule (`oci_image`, or `container_image` in this case) must set a proper `workdir` and `cmd` to for the container work.
A proper `cmd` usually looks like /`[ root of py_image_layer ]`/`[ relative path to BUILD file from WORKSPACE or package_name() ]/[ name of py_binary ]`, 
unless you have a launcher script that invokes the entry_point of the `py_binary` in a different path.
On the other hand, `workdir` has to be set to `runfiles tree root` which would be exactly `cmd` **but with `.runfiles/[ name of the workspace or __main__ if empty ]` suffix**. If `workdir` is not set correctly, some
attributes such as `chdir` might not work properly.

py_image_layer supports transitioning to specific `platform` to allow building multi-platform container images.

> WARNING: Structure of the resulting layers are not subject to semver guarantees and may change without a notice. However, it is guaranteed to work when provided together in the `app` and `site_packages` order

**A partial example using rules_oci with transition to linux/amd64 platform.**

```starlark
load("@aspect_rules_js//js:defs.bzl", "py_binary", "py_image_layer")
load("@rules_oci//oci:defs.bzl", "oci_image")

py_binary(
    name = "binary",
    entry_point = "main.js",
)

platform(
    name = "amd64_linux",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
)

py_image_layer(
    name = "layers",
    binary = ":binary",
    platform = ":amd64_linux",
    root = "/app"
)

oci_image(
    name = "image",
    cmd = ["/app/main"],
    entrypoint = ["bash"],
    tars = [
        ":layers"
    ]
)
```

**A partial example using rules_oci to create multi-platform images.**


```starlark
load("@aspect_rules_js//js:defs.bzl", "py_binary", "py_image_layer")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_image_index")

py_binary(
    name = "binary",
    entry_point = "main.js",
)

[
    platform(
        name = "linux_{}".format(arch),
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:{}".format(arch if arch != "amd64" else "x86_64"),
        ],
    )
    py_image_layer(
        name = "{}_layers".format(arch),
        binary = ":binary",
        platform = ":linux_{arch}",
        root = "/app"
    )
    oci_image(
        name = "{}_image".format(arch),
        cmd = ["/app/main"],
        entrypoint = ["bash"],
        tars = [
            ":{}_layers".format(arch)
        ]
    )
    for arch in ["amd64", "arm64"]
]

oci_image_index(
    name = "image",
    images = [
        ":arm64_image",
        ":amd64_image"
    ]
)

```

**An example using legacy rules_docker**

See `e2e/js_image_rules_docker` for full example.

```starlark
load("@aspect_rules_js//js:defs.bzl", "py_binary", "py_image_layer")
load("@io_bazel_rules_docker//container:container.bzl", "container_image")

py_binary(
    name = "main",
    data = [
        "//:site_packages/args-parser",
    ],
    entry_point = "main.js",
)


py_image_layer(
    name = "layers",
    binary = ":main",
    root = "/app",
    visibility = ["//visibility:__pkg__"],
)

filegroup(
    name = "app_tar", 
    srcs = [":layers"], 
    output_group = "app"
)
container_layer(
    name = "app_layer",
    tars = [":app_tar"],
)

filegroup(
    name = "site_packages_tar", 
    srcs = [":layers"], 
    output_group = "site_packages"
)
container_layer(
    name = "site_packages_layer",
    tars = [":site_packages_tar"],
)

container_image(
    name = "image",
    cmd = ["/app/main"],
    entrypoint = ["bash"],
    layers = [
        ":app_layer",
        ":site_packages_layer",
    ],
)
```
"""

def _runfile_path(ctx, file, runfiles_dir):
    return paths.join(runfiles_dir, to_rlocation_path(ctx, file))

def _runfiles_dir(root, default_info):
    manifest = default_info.files_to_run.runfiles_manifest

    nobuild_runfile_links_is_set = manifest.short_path.endswith("_manifest")

    if nobuild_runfile_links_is_set:
        # When `--nobuild_runfile_links` is set, runfiles_manifest points to the manifest
        # file sitting adjacent to the runfiles tree rather than within it.
        runfiles = default_info.files_to_run.runfiles_manifest.short_path.replace("_manifest", "")
    else:
        runfiles = manifest.short_path.replace(manifest.basename, "")[:-1]

    return paths.join(root, runfiles.replace(".sh", ""))

def _build_layer(ctx, type, entries, inputs):
    entries_output = ctx.actions.declare_file("{}_{}_entries.json".format(ctx.label.name, type))
    ctx.actions.write(entries_output, content = json.encode(entries))

    extension = "tar.gz" if ctx.attr.compression == "gzip" else "tar"
    output = ctx.actions.declare_file("{name}_{type}.{extension}".format(name = ctx.label.name, type = type, extension = extension))

    args = ctx.actions.args()
    args.add(entries_output)
    args.add(output)
    args.add(ctx.attr.compression)
    if not is_bazel_6_or_greater():
        args.add("true")

    ctx.actions.run(
        inputs = inputs + [entries_output],
        outputs = [output],
        arguments = [args],
        executable = ctx.executable._builder,
        progress_message = "PyImageLayer %{label}",
        env = {
            "BAZEL_BINDIR": ".",
        },
    )

    return output

def _should_be_in_site_packages_layer(destination, _file):
    is_site_packages = "/site-packages/" in destination
    return is_site_packages

def _should_be_in_python3_layer(destination, _file):
    # print("destination!", destination)
    is_python3 = "/python_3_10_x86_64-unknown-linux-gnu/" in destination
    return is_python3

def _py_image_layer_impl(ctx):
    if len(ctx.attr.binary) != 1:
        fail("binary attribute has more than one transition")

    default_info = ctx.attr.binary[0][DefaultInfo]
    # default_info = ctx.attr.binary[DefaultInfo]

    runfiles_dir = _runfiles_dir(ctx.attr.root, default_info)
    # executable = default_info.files_to_run.executable

    all_files = depset(transitive = [default_info.files, default_info.default_runfiles.files])

    app_entries = {}
    app_inputs = []

    site_packages_entries = {}
    site_packages_inputs = []

    python3_entries = {}
    python3_inputs = []

    for file in all_files.to_list():
        # print("file: %s" % file.short_path)
        destination = _runfile_path(ctx, file, runfiles_dir)
        entry = {
            "dest": file.path,
            "root": file.root.path,
            "is_external": file.owner.workspace_name != "",
            "is_source": file.is_source,
            "is_directory": file.is_directory,
        }

        if _should_be_in_python3_layer(destination, file):
            python3_entries[destination] = entry
            python3_inputs.append(file)
        elif _should_be_in_site_packages_layer(destination, file):
            site_packages_entries[destination] = entry
            site_packages_inputs.append(file)
        else:
            app_entries[destination] = entry
            app_inputs.append(file)

    app = _build_layer(ctx, type = "app", entries = app_entries, inputs = app_inputs)
    site_packages = _build_layer(ctx, type = "site_packages", entries = site_packages_entries, inputs = site_packages_inputs)
    python3 = _build_layer(ctx, type = "python3", entries = python3_entries, inputs = python3_inputs)

    return [
        DefaultInfo(files = depset([app, site_packages, python3])),
        OutputGroupInfo(
            app = depset([app]),
            site_packages = depset([site_packages]),
            python3 = depset([python3]),
        ),
    ]

def _py_image_layer_transition_impl(settings, attr):
    # buildifier: disable=unused-variable
    _ignore = (settings)
    if not attr.platform:
        return {}
    return {
        "//command_line_option:platforms": str(attr.platform),
    }

_py_image_layer_transition = transition(
    implementation = _py_image_layer_transition_impl,
    inputs = [],
    outputs = ["//command_line_option:platforms"],
)

py_image_layer_lib = struct(
    implementation = _py_image_layer_impl,
    attrs = {
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
        ),
        "binary": attr.label(
            mandatory = True,
            cfg = _py_image_layer_transition,
            doc = "Label to a py_binary target",
        ),
        "_builder": attr.label(
            default = "@aspect_rules_js//js/private:js_image_layer_builder",
            executable = True,
            cfg = "exec",
        ),
        "root": attr.string(
            doc = "Path where the files from py_binary will reside in. eg: /apps/app1 or /app",
        ),
        "compression": attr.string(
            doc = "Compression algorithm. Can be one of `gzip`, `none`.",
            values = ["gzip", "none"],
            default = "gzip",
        ),
        "platform": attr.label(
            doc = "Platform to transition.",
        ),
    },
)

py_image_layer = rule(
    implementation = py_image_layer_lib.implementation,
    attrs = py_image_layer_lib.attrs,
    doc = _DOC,
)
