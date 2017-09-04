# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("@bazel_toolbox//assert:assert.bzl",
    "assert_files_equal",
    "assert_label_providers",
)

load("//site_zip:site_zip.bzl",
    "zip_server",
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

# Add minify_site_zip tests

# Add rename_zip_paths tests

zip_server(
    name = "basic_zip_server",
    zip = "empty.zip",
)

zip_server(
    name = "full_zip_server",
    zip = "data.zip",
    host = "0.0.0.0",
    port = 1234,
)

py_test(
    name = "test_full_zip_server",
    srcs = [ "test_full_zip_server.py" ],
    data = [ ":full_zip_server" ],
)
