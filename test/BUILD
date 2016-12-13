# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load(":internal_test.bzl", "run_all_tests")

run_all_tests()

py_binary(
    name = "assert_equal",
    srcs = [
        "scripts/assert_equal.py",
    ],
    visibility = [ "//visibility:public" ],
)

py_binary(
    name = "assert_descending_sizes",
    srcs = [
        "scripts/assert_descending_sizes.py",
    ],
    visibility = [ "//visibility:public" ],
)

py_binary(
    name = "assert_valid_type",
    srcs = [
        "scripts/assert_valid_type.py",
    ],
    deps = [ "@pillow//:pillow" ],
    visibility = [ "//visibility:public" ],
)
