# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("@bazel_toolbox//assert:assert.bzl",
    "assert_files_equal",
    "assert_label_providers",
)

load("//site_zip:site_zip.bzl",
    "zip_site",
)

load("//test:test.bzl",
    "assert_valid_type",
)

zip_site(
    name = "empty_zip_site_test",
    out_zip = "empty_zip_site_test_out",
)
assert_files_equal("empty.zip", ":empty_zip_site_test")