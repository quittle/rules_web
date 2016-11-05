# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//html:html.bzl",
    "minify_html",
)

load("//test:test.bzl",
    "assert_equal",
    "assert_descending_sizes",
    "assert_valid_type",
)

minify_html(
    name = "test_minify_html",
    src = "test.html",
)
assert_equal("expected.html", ":test_minify_html")
assert_valid_type(":test_minify_html", "html")
assert_descending_sizes([ "test.html", ":test_minify_html" ])
