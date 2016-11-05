# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//html:html.bzl",
    "html_page",
    "minify_html",
)

load("//test:test.bzl",
    "assert_equal",
    "assert_descending_sizes",
    "assert_valid_type",
)

html_page(
    name = "test_html_page",
    config = "config.json",
    body = "body.html",
    deferred_js_files = [ "test_deferred.js" ],
    js_files = [ "test.js" ],
    css_files = [ "test.css" ],
    favicon_images = [ "favicon.png" ],
    favicon_sizes = [ 16 ],
    deps = [ "dep.txt" ],
)
assert_valid_type(":test_html_page", "html")
minify_html(
    name = "minify_test_html_page",
    src = ":test_html_page",
)
minify_html(
    name = "minify_expected_test_html_page",
    src = "test_html_page_expected_unminified.html",
)
assert_equal(":minify_expected_test_html_page", ":minify_test_html_page")

minify_html(
    name = "test_minify_html",
    src = "test.html",
)
assert_equal("expected.html", ":test_minify_html")
assert_valid_type(":test_minify_html", "html")
assert_descending_sizes([ "test.html", ":test_minify_html" ])
