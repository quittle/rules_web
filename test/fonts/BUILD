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
    "assert_label_struct",
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
assert_label_struct(
    ":test_font_generator",
    {
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
    srcs = [ ":test_font_generator" ],
)
assert_label_struct(
    ":validate_test_font_generator_css",
    {
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
assert_descending_sizes([ "test_roboto.ttf", ":test_minify_ttf_roboto" ])
assert_label_struct(
    ":test_minify_ttf_roboto",
    {
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
assert_descending_sizes([ "test_raleway.ttf", ":test_minify_ttf_raleway" ])
assert_label_struct(
    ":test_minify_ttf_raleway",
    {
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
assert_label_struct(
    ":test_ttf_to_eot",
    {
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
assert_label_struct(
    ":test_ttf_to_woff",
    {
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
assert_descending_sizes([ ":test_ttf_to_woff", ":test_ttf_to_woff2" ])
assert_label_struct(
    ":test_ttf_to_woff2",
    {
        "css_resources": [],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [
            "{GEN_DIR}/test/fonts/test_ttf_to_woff2__generated.woff2",
        ],
        "source_map": {},
    },
)
