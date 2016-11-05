# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//fonts:fonts.bzl",
    "minify_ttf",
)

load("//test:test.bzl",
    "assert_descending_sizes",
)

# TOOD: Add font_generator tests

minify_ttf(
    name = "test_minify_ttf_roboto",
    ttf = "test_roboto.ttf",
)
assert_descending_sizes([ "test_roboto.ttf", ":test_minify_ttf_roboto" ])

minify_ttf(
    name = "test_minify_ttf_raleway",
    ttf = "test_raleway.ttf",
)
assert_descending_sizes([ "test_raleway.ttf", ":test_minify_ttf_raleway" ])