# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load("@bazel_toolbox//assert:assert.bzl",
    "assert_files_equal",
    "assert_label_providers",
)

load("//generate:generate.bzl",
    "generate_variables",
)

load("//test:test.bzl",
    "assert_valid_type",
)

generate_variables(
    name = "test_generate_variables_js",
    config = "test.json",
    out_js = "test_generate_variables.js",
)
assert_files_equal(":expected_generate_variables.js", ":test_generate_variables_js")
assert_valid_type(":test_generate_variables_js", "js")
assert_label_providers(
    ":test_generate_variables_js",
    {
        "aspect_ids": [],
        "css_resources": [],
        "deferred_js_resources": [],
        "js_resources": [
            "{BIN_DIR}/test/generate/test_generate_variables.js",
        ],
        "resources": [],
        "source_map": {},
    },
)

generate_variables(
    name = "test_generate_variables_scss",
    config = "test.json",
    out_scss = "test_generate_variables.scss",
)
assert_files_equal(":expected_generate_variables.scss", ":test_generate_variables_scss")
assert_valid_type(":test_generate_variables_scss", "scss")
assert_label_providers(
    ":test_generate_variables_scss",
    {
        "aspect_ids": [],
        "css_resources": [],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [
            "{BIN_DIR}/test/generate/test_generate_variables.scss",
        ],
        "source_map": {},
    },
)

generate_variables(
    name = "test_generate_variables_css",
    config = "test.json",
    out_css = "test_generate_variables.css",
)
assert_files_equal(":expected_generate_variables.css", ":test_generate_variables_css")
assert_valid_type(":test_generate_variables_css", "css")
assert_label_providers(
    ":test_generate_variables_css",
    {
        "aspect_ids": [],
        "css_resources": [
            "{BIN_DIR}/test/generate/test_generate_variables.css",
        ],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [],
        "source_map": {},
    },
)
