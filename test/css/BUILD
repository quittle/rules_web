# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//css:css.bzl",
    "minify_css",
)

load("//test:test.bzl",
    "assert_descending_sizes",
    "assert_equal",
    "assert_label_struct",
)

minify_css(
    name = "test_minify_css",
    srcs = [ "test.css" ],
)
assert_equal(":expected_minify.css", ":test_minify_css")
assert_descending_sizes([ "test.css", ":test_minify_css" ])
assert_label_struct(
    ":test_minify_css",
    {
        "css_resources": [
            "{BIN_DIR}/test/css/test_minify_css.min.css",
        ],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [],
        "source_map": {},
    },
)
