"example.bzl provides the gazelle_testdata_example rule."

load("@io_bazel_rules_go//go/tools/bazel_testing:def.bzl", "go_bazel_test")

def _example_gen_impl(ctx):
    config = struct(
        name = ctx.label.name,
        label = str(ctx.label),
        testOut = ctx.outputs.test.path,
        testContent = ctx.attr.test_content,
        workspaceIn = ctx.file.workspace_template.path,
        stripPrefix = ctx.attr.strip_prefix,
        files = [f.path for f in ctx.files.srcs],
    )

    ctx.actions.write(
        output = ctx.outputs.json,
        content = config.to_json(),
    )

    ctx.actions.run(
        mnemonic = "ExampleGen",
        progress_message = "Generating %s test" % ctx.attr.name,
        executable = ctx.file._generator,
        arguments = ["--config_json=%s" % ctx.outputs.json.path],
        inputs = [ctx.outputs.json, ctx.file.workspace_template] + ctx.files.srcs,
        outputs = [ctx.outputs.test],
    )

    return [DefaultInfo(
        files = depset([ctx.outputs.json, ctx.outputs.test]),
    )]

_example_gen = rule(
    implementation = _example_gen_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "Sources for the test txtar file",
            allow_files = True,
        ),
        "strip_prefix": attr.string(
            doc = "path prefix to remove from test files in the txtar",
        ),
        "test_content": attr.string(
            doc = "optional chunk of golang test content.  Default behavior is 'bazel build ...'",
            default = """
func TestBuild(t *testing.T) {
	if err := bazel_testing.RunBazel("build", "..."); err != nil {
		t.Fatal(err)
	}
}
""",
        ),
        "workspace_template": attr.label(
            doc = "Template for the test WORKSPACE",
            allow_single_file = True,
            mandatory = True,
        ),
        "_generator": attr.label(
            doc = "The exampl generator tool",
            default = "//bazel/tools/example_test/generator",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
    },
    outputs = {
        "json": "%{name}.json",
        "test": "%{name}_test.go",
    },
)

def example_test(**kwargs):
    """
    example_test rule runs an go_bazel_test for an example dir

    Args:
        **kwargs: the kwargs dict passed to 'go_bazel_test'
    """
    name = kwargs.pop("name")
    srcs = kwargs.pop("srcs", [])
    strip_prefix = kwargs.pop("strip_prefix", "")
    gen_name = name + "_gen"

    test_content = kwargs.pop("test_content", None)
    rule_files = kwargs.pop("rule_files", ["//:example_test_files"])

    _example_gen(
        name = gen_name,
        srcs = srcs,
        strip_prefix = strip_prefix,
        test_content = test_content,
        workspace_template = kwargs.pop("workspace_template", ""),
    )

    go_bazel_test(
        name = name,
        srcs = [gen_name + "_test.go"],
        rule_files = rule_files,
        **kwargs
    )

def example_test_filegroup(name, **kwargs):
    native.filegroup(
        name = name,
        testonly = True,
        visibility = ["//visibility:public"],
        **kwargs
    )
