# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//js:js.bzl",
    "closure_compile",
    "minify_js",
)

load("//test:test.bzl",
    "assert_descending_sizes",
    "assert_equal",
)

# TODO: Add resource_map test

minify_js(
    name = "test_minify_js",
    srcs = [ "test.js" ],
)

assert_equal(":expected_minify.js", ":test_minify_js")
assert_descending_sizes([ "test.js", ":test_minify_js" ])

closure_compile(
    name = "test_closure_compile",
    srcs = [ "test.js" ],
)

assert_equal(":expected_closure_compile.js", ":test_closure_compile")
assert_descending_sizes([ "test.js", ":test_closure_compile" ])