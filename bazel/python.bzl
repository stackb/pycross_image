load("@rules_python//python:defs.bzl", _py_binary = "py_binary")
load("@//bazel/python:py_oci_image.bzl", _pycross_oci_image = "pycross_oci_image")

py_binary = _py_binary
pycross_image = _pycross_oci_image

def requirement(name):
    return "@poetry//:{}".format(name)
