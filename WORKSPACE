workspace(name = "pycross_image")

# -----------------------------------------

load("@pycross_image//bazel:repositories.bzl", "repositories")

repositories()

# -----------------------------------------

load("@pycross_image//bazel:step1.bzl", "step1")

step1.setup_zig_toolchains()

step1.setup_rules_go()

step1.setup_bazel_gazelle()

step1.setup_bazel_skylib()

step1.setup_rules_python()

step1.setup_aspect_bazel_lib()

step1.setup_rules_oci()

step1.setup_rules_docker()

# -----------------------------------------

load("@pycross_image//bazel:step2.bzl", "step2")

step2.setup_oci_containers()

step2.setup_docker_containers()

step2.setup_rules_pycross()

# -----------------------------------------

load("@pycross_image//bazel:step3.bzl", "step3")

step3.setup_pypi_deps_for_pdm()

# -----------------------------------------

load("@pycross_image//bazel:step4.bzl", "step4")

step4.install_pypi_deps_for_pdm()
