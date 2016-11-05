# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//css:css.bzl",
    "minify_css",
)

load("//test:test.bzl",
    "assert_descending_sizes",
    "assert_equal",
)

minify_css(
    name = "test_minify_css",
    srcs = [ "test.css" ],
)

assert_equal(":expected_minify.css", ":test_minify_css")
assert_descending_sizes([ "test.css", ":test_minify_css" ])
