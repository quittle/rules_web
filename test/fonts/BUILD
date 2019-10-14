# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load(
    "@bazel_toolbox//assert:assert.bzl",
    "assert_label_providers",
)
load(
    "//css:css.bzl",
    "minify_css",
)
load(
    "//fonts:fonts.bzl",
    "font_generator",
    "minify_ttf",
    "ttf_to_eot",
    "ttf_to_woff",
    "ttf_to_woff2",
)
load(
    "//test:test.bzl",
    "assert_descending_sizes",
)

font_generator(
    name = "test_font_generator",
    eot = ":test_ttf_to_eot",
    font_name = "font_name",
    style = "italic",
    ttf = "test_roboto.ttf",  # Use a local file instead of a generated one
    weight = "bolder",
    woff = ":test_ttf_to_woff",
    woff2 = ":test_ttf_to_woff2",
)

assert_label_providers(
    ":test_font_generator",
    {
        "actions": [None],
        "css_resources": [
            "{GEN_DIR}/test/fonts/test_font_generator__generated.css",
        ],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [
            "{GEN_DIR}/test/fonts/test_ttf_to_woff2__generated.woff2",
            "{GEN_DIR}/test/fonts/test_ttf_to_woff__generated.woff",
            "test/fonts/test_roboto.ttf",
            "{GEN_DIR}/test/fonts/test_ttf_to_eot__generated.eot",
        ],
        "source_map": {},
    },
)

minify_css(
    name = "validate_test_font_generator_css",
    srcs = [":test_font_generator"],
)

assert_label_providers(
    ":validate_test_font_generator_css",
    {
        "actions": [None],
        "css_resources": [
            "{BIN_DIR}/test/fonts/validate_test_font_generator_css.min.css",
        ],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [
            "{GEN_DIR}/test/fonts/test_ttf_to_woff2__generated.woff2",
            "{GEN_DIR}/test/fonts/test_ttf_to_woff__generated.woff",
            "test/fonts/test_roboto.ttf",
            "{GEN_DIR}/test/fonts/test_ttf_to_eot__generated.eot",
        ],
        "source_map": {},
    },
)

minify_ttf(
    name = "test_minify_ttf_roboto",
    ttf = "test_roboto.ttf",
)

assert_descending_sizes([
    "test_roboto.ttf",
    ":test_minify_ttf_roboto",
])

assert_label_providers(
    ":test_minify_ttf_roboto",
    {
        "actions": [
            None,
            None,
            None,
        ],
        "css_resources": [],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [
            "{GEN_DIR}/test/fonts/test_minify_ttf_roboto__minified.ttf",
        ],
        "source_map": {
            "test/fonts/test_roboto.ttf": "{GEN_DIR}/test/fonts/test_minify_ttf_roboto__minified.ttf",
        },
    },
)

minify_ttf(
    name = "test_minify_ttf_raleway",
    ttf = "test_raleway.ttf",
)

assert_descending_sizes([
    "test_raleway.ttf",
    ":test_minify_ttf_raleway",
])

assert_label_providers(
    ":test_minify_ttf_raleway",
    {
        "actions": [
            None,
            None,
            None,
        ],
        "css_resources": [],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [
            "{GEN_DIR}/test/fonts/test_minify_ttf_raleway__minified.ttf",
        ],
        "source_map": {
            "test/fonts/test_raleway.ttf": "{GEN_DIR}/test/fonts/test_minify_ttf_raleway__minified.ttf",
        },
    },
)

ttf_to_eot(
    name = "test_ttf_to_eot",
    ttf = "test_roboto.ttf",
)

assert_label_providers(
    ":test_ttf_to_eot",
    {
        "actions": [None],
        "css_resources": [],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [
            "{GEN_DIR}/test/fonts/test_ttf_to_eot__generated.eot",
        ],
        "source_map": {},
    },
)

ttf_to_woff(
    name = "test_ttf_to_woff",
    ttf = "test_roboto.ttf",
)

assert_label_providers(
    ":test_ttf_to_woff",
    {
        "actions": [
            None,
            None,
        ],
        "css_resources": [],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [
            "{GEN_DIR}/test/fonts/test_ttf_to_woff__generated.woff",
        ],
        "source_map": {},
    },
)

ttf_to_woff2(
    name = "test_ttf_to_woff2",
    ttf = "test_roboto.ttf",
)

assert_descending_sizes([
    ":test_ttf_to_woff",
    ":test_ttf_to_woff2",
])

assert_label_providers(
    ":test_ttf_to_woff2",
    {
        "actions": [
            None,
            None,
        ],
        "css_resources": [],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [
            "{GEN_DIR}/test/fonts/test_ttf_to_woff2__generated.woff2",
        ],
        "source_map": {},
    },
)
