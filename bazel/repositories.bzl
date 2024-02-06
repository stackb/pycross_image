load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def repositories():
    # Release: 0.29.0
    # TargetCommitish: main
    # Date: 2024-01-22 20:05:28 +0000 UTC
    # URL: https://github.com/bazelbuild/rules_python/releases/tag/0.29.0
    # Size: 536376 (536 kB)
    http_archive(
        name = "rules_python",
        sha256 = "d71d2c67e0bce986e1c5a7731b4693226867c45bfe0b7c5e0067228a536fc580",
        strip_prefix = "rules_python-0.29.0",
        urls = ["https://github.com/bazelbuild/rules_python/archive/0.29.0.tar.gz"],
    )

    # Release: v0.5.1
    # TargetCommitish: main
    # Date: 2024-01-31 07:52:36 +0000 UTC
    # URL: https://github.com/jvolkman/rules_pycross/releases/tag/v0.5.1
    # Size: 148954 (149 kB)
    http_archive(
        name = "rules_pycross",
        sha256 = "edc0ccb8b95a0064f130fa3e7f5d690af9f120243cab72858a265738847e3d51",
        strip_prefix = "rules_pycross-0.5.1",
        urls = ["https://github.com/jvolkman/rules_pycross/archive/v0.5.1.tar.gz"],
    )

    # Release: v2.2.1
    # TargetCommitish: main
    # Date: 2024-01-12 07:47:12 +0000 UTC
    # URL: https://github.com/uber/hermetic_cc_toolchain/releases/tag/v2.2.1
    # Size: 45513 (46 kB)
    http_archive(
        name = "hermetic_cc_toolchain",
        sha256 = "1a9ad181cf1c112b2e5d942fb0a71afa6da24e5b35110c3e129214a7e0459dcd",
        strip_prefix = "hermetic_cc_toolchain-2.2.1",
        urls = ["https://github.com/uber/hermetic_cc_toolchain/archive/v2.2.1.tar.gz"],
    )

    # Release: v0.40.1
    # TargetCommitish: v0.40.1
    # URL: https://github.com/bazelbuild/rules_go/releases/tag/v0.40.1
    http_archive(
        name = "io_bazel_rules_go",
        sha256 = "51dc53293afe317d2696d4d6433a4c33feedb7748a9e352072e2ec3c0dafd2c6",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.40.1/rules_go-v0.40.1.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.40.1/rules_go-v0.40.1.zip",
        ],
    )

    # Release: v0.35.0
    # TargetCommitish: master
    # Date: 2023-12-21 16:38:31 +0000 UTC
    # URL: https://github.com/bazelbuild/bazel-gazelle/releases/tag/v0.35.0
    # Size: 1780790 (1.8 MB)
    http_archive(
        name = "bazel_gazelle",
        sha256 = "a0ee1d304f7caa46680ba06bdef0e5d9ec8815f6e01ec29398efd13256598c3f",
        strip_prefix = "bazel-gazelle-0.35.0",
        urls = ["https://github.com/bazelbuild/bazel-gazelle/archive/v0.35.0.tar.gz"],
    )

    # Release: v0.25.0
    # TargetCommitish: master
    # Date: 2022-06-22 09:25:13 +0000 UTC
    # URL: https://github.com/bazelbuild/rules_docker/releases/tag/v0.25.0
    # Size: 600954 (601 kB)
    http_archive(
        name = "io_bazel_rules_docker",
        sha256 = "07ee8ca536080f5ebab6377fc6e8920e9a761d2ee4e64f0f6d919612f6ab56aa",
        strip_prefix = "rules_docker-0.25.0",
        urls = ["https://github.com/bazelbuild/rules_docker/archive/v0.25.0.tar.gz"],
    )

    # Release: v2.3.0
    # TargetCommitish: main
    # Date: 2024-01-10 23:07:03 +0000 UTC
    # URL: https://github.com/aspect-build/bazel-lib/releases/tag/v2.3.0
    # Size: 190487 (190 kB)
    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "bda4a69fa50411b5feef473b423719d88992514d259dadba7d8218a1d02c7883",
        strip_prefix = "bazel-lib-2.3.0",
        urls = ["https://github.com/aspect-build/bazel-lib/archive/v2.3.0.tar.gz"],
    )

    # Release: v1.7.0
    # TargetCommitish: main
    # Date: 2024-02-02 21:41:03 +0000 UTC
    # URL: https://github.com/bazel-contrib/rules_oci/releases/tag/v1.7.0
    # Size: 128704 (129 kB)
    http_archive(
        name = "rules_oci",
        sha256 = "6ae66ccc6261d3d297fef1d830a9bb852ddedd3920bbd131021193ea5cb5af77",
        strip_prefix = "rules_oci-1.7.0",
        urls = ["https://github.com/bazel-contrib/rules_oci/archive/v1.7.0.tar.gz"],
    )

    # Release: 1.5.0
    # TargetCommitish: main
    # Date: 2023-11-05 16:16:45 +0000 UTC
    # URL: https://github.com/bazelbuild/bazel-skylib/releases/tag/1.5.0
    # Size: 112573 (113 kB)
    http_archive(
        name = "bazel_skylib",
        sha256 = "118e313990135890ee4cc8504e32929844f9578804a1b2f571d69b1dd080cfb8",
        strip_prefix = "bazel-skylib-1.5.0",
        urls = ["https://github.com/bazelbuild/bazel-skylib/archive/1.5.0.tar.gz"],
    )
