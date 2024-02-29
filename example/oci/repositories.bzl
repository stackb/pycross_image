load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def repositories():
    # Commit: c010a3b95427ddfa678e92250e4bcf7d95cf39ce
    # Date: 2024-02-27 16:03:55 +0000 UTC
    # URL: https://github.com/GoogleContainerTools/container-structure-test/commit/c010a3b95427ddfa678e92250e4bcf7d95cf39ce
    #
    # Release v1.17.0
    #
    # Signed-off-by: Appu Goundan <appu@google.com>
    # Size: 61740 (62 kB)
    http_archive(
        name = "container_structure_test",
        sha256 = "df5043d1edef7c06f8ba94cb8b383b4a9cb4bdcf90db4b9c312a6a8ddd336916",
        strip_prefix = "container-structure-test-c010a3b95427ddfa678e92250e4bcf7d95cf39ce",
        urls = ["https://github.com/GoogleContainerTools/container-structure-test/archive/c010a3b95427ddfa678e92250e4bcf7d95cf39ce.tar.gz"],
    )
