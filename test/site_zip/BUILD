# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load(
    "@bazel_toolbox//assert:assert.bzl",
    "assert_files_equal",
    "assert_label_providers",
)
load(
    "//site_zip:site_zip.bzl",
    "zip_server",
    "zip_site",
)
load(
    "//test:test.bzl",
    "assert_valid_type",
)

zip_site(
    name = "empty_zip_site_test",
    out_zip = "empty_zip_site_test_out",
)

assert_files_equal("empty.zip", ":empty_zip_site_test")

filegroup(
    name = "zip_site_filegroup",
    srcs = [
        "data.txt",
    ],
)

zip_site(
    name = "zip_site_test",
    out_zip = "zip_site_test_out",
    resources = [":zip_site_filegroup"],
    root_files = [":zip_site_filegroup"],
)

# Add minify_site_zip tests

# Add rename_zip_paths tests

zip_server(
    name = "basic_zip_server",
    zip = "empty.zip",
)

zip_server(
    name = "full_zip_server",
    host = "0.0.0.0",
    port = 1234,
    zip = "data.zip",
)

py_test(
    name = "test_full_zip_server",
    srcs = ["test_full_zip_server.py"],
    data = [":full_zip_server"],
)
