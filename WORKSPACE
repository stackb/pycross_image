workspace(name = "pycross_image")

# -----------------------------------------

load("@pycross_image//bazel/workspace:repositories.bzl", "repositories")

repositories()

# -----------------------------------------

load("@pycross_image//bazel/workspace:step1.bzl", "step1")

step1.setup_zig_toolchains()

step1.setup_rules_go()

step1.setup_bazel_gazelle()

step1.setup_bazel_skylib()

step1.setup_rules_python()

step1.setup_aspect_bazel_lib()

step1.setup_rules_oci()

step1.setup_rules_docker()

step1.setup_container_structure_test()

# -----------------------------------------

load("@pycross_image//bazel/workspace:step2.bzl", "step2")

step2.setup_pycross_image_base_oci()

step2.setup_pycross_image_base_container()

step2.setup_rules_pycross()

# -----------------------------------------

load("@pycross_image//bazel/workspace:step3.bzl", "step3")

step3.setup_pypi_deps_for_pdm()

# -----------------------------------------

load("@pycross_image//bazel/workspace:step4.bzl", "step4")

step4.install_pypi_deps_for_pdm()
