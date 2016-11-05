# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//css:css.bzl",
    "minify_css",
)

load("//fonts:fonts.bzl",
    "font_generator",
    "minify_ttf",
    "ttf_to_eot",
    "ttf_to_woff",
    "ttf_to_woff2",
)

load("//test:test.bzl",
    "assert_descending_sizes",
    "assert_valid_type",
)

font_generator(
    name = "test_font_generator",
    font_name = "font_name",
    eot = ":test_ttf_to_eot",
    ttf = "test_roboto.ttf", # Use a local file instead of a generated one
    woff = ":test_ttf_to_woff",
    woff2 = ":test_ttf_to_woff2",
    weight = "bolder",
    style = "italic",
)
minify_css(
    name = "validate_test_font_generator_css",
    srcs = [ ":test_font_generator" ],
)

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

ttf_to_eot(
    name = "test_ttf_to_eot",
    ttf = "test_roboto.ttf",
)

ttf_to_woff(
    name = "test_ttf_to_woff",
    ttf = "test_roboto.ttf",
)

ttf_to_woff2(
    name = "test_ttf_to_woff2",
    ttf = "test_roboto.ttf",
)
assert_descending_sizes([ ":test_ttf_to_woff", ":test_ttf_to_woff2" ])
