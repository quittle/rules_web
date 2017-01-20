# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load("@bazel_toolbox//assert:assert.bzl",
    "assert_files_equal",
    "assert_label_providers",
)

load("//html:html.bzl",
    "html_page",
    "minify_html",
)

load("//test:test.bzl",
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
assert_label_providers(
    ":test_html_page",
    {
        "css_resources": [
            "test/html/test.css",
        ],
        "deferred_js_resources": [
            "test/html/test_deferred.js",
        ],
        "js_resources": [
            "test/html/test.js",
        ],
        "resources": [
            "test/html/dep.txt",
            "test/html/favicon.png",
            "{BIN_DIR}/test/html/test_html_page.html",
        ],
        "source_map": {
            "test/html/dep.txt": "test/html/dep.txt",
            "test/html/test_html_page.html": "{BIN_DIR}/test/html/test_html_page.html",
        },
    },
)
minify_html(
    name = "minify_test_html_page",
    src = ":test_html_page",
)
assert_label_providers(
    ":minify_test_html_page",
    {
        "css_resources": [
            "test/html/test.css",
        ],
        "deferred_js_resources": [
            "test/html/test_deferred.js",
        ],
        "js_resources": [
            "test/html/test.js",
        ],
        "resources": [
            "{BIN_DIR}/test/html/minify_test_html_page.min.html",
            "test/html/favicon.png",
            "test/html/dep.txt",
        ],
        "source_map": {
            "test/html/dep.txt": "test/html/dep.txt",
            "test/html/test_html_page.html": "{BIN_DIR}/test/html/minify_test_html_page.min.html",
        },
    },
)
minify_html(
    name = "minify_expected_test_html_page",
    src = "test_html_page_expected_unminified.html",
)
assert_files_equal(":minify_expected_test_html_page", ":minify_test_html_page")

minify_html(
    name = "test_minify_html",
    src = "test.html",
)
assert_files_equal("expected.html", ":test_minify_html")
assert_valid_type(":test_minify_html", "html")
assert_descending_sizes([ "test.html", ":test_minify_html" ])
assert_label_providers(
    ":test_minify_html",
    {
        "resources": [
            "{BIN_DIR}/test/html/test_minify_html.min.html",
        ],
        "source_map": {
            "test/html/test.html": "{BIN_DIR}/test/html/test_minify_html.min.html",
        },
    },
)
