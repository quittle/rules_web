# Copyright (c) 2016-2016 Dustin Toff
# Licensed under Apache License v2.0

load(
    "@bazel_toolbox//assert:assert.bzl",
    "assert_files_equal",
    "assert_label_providers",
)
load(
    "@bazel_toolbox//collections:collections.bzl",
    "reverse",
)
load(
    "//html:html.bzl",
    "html_page",
    "inject_html",
    "minify_html",
    "validate_html",
)
load(
    "//test:test.bzl",
    "assert_descending_sizes",
    "assert_valid_type",
)

html_page(
    name = "test_html_page",
    body = "body.html",
    config = "config.json",
    css_files = ["test.css"],
    deferred_js_files = ["test_deferred.js"],
    favicon_images = ["favicon.png"],
    favicon_sizes = [16],
    inline_js_files = ["test.js"],
    js_files = ["test.js", "//test/js:test_resource_map"],
    deps = ["dep.txt", "//test/js:test_resource_map"],
)

assert_valid_type(":test_html_page", "html")

assert_label_providers(
    ":test_html_page",
    {
        "actions": [None],
        "css_resources": [
            "test/html/test.css",
        ],
        "deferred_js_resources": [
            "test/html/test_deferred.js",
        ],
        "js_resources": [
            "test/html/test.js",
            "{BIN_DIR}/test/js/resource_map/test_resource_map.js",
            "{BIN_DIR}/test/js/closure_compile/test_closure_compile.js",
            "{BIN_DIR}/test/js/minify_js/test_minify_js.min.js"
        ],
        # No inline_js_files as it has been inlined
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

validate_html(
    name = "validate_test_html_page",
    src = ":test_html_page",
)

minify_html(
    name = "minify_test_html_page",
    src = ":test_html_page",
)

# This is re-used by inject_html tests
minify_test_html_page_providers = {
    "actions": [None],
    "css_resources": [
        "test/html/test.css",
    ],
    "deferred_js_resources": [
        "test/html/test_deferred.js",
    ],
    "js_resources": [
        "{BIN_DIR}/test/js/minify_js/test_minify_js.min.js",
        "{BIN_DIR}/test/js/closure_compile/test_closure_compile.js",
        "{BIN_DIR}/test/js/resource_map/test_resource_map.js",
        "test/html/test.js",
    ],
    "resources": [
        "{BIN_DIR}/test/html/minify_test_html_page.min.html",
        "test/html/favicon.png",
        "test/html/dep.txt",
    ],
    "source_map": {
        "test/html/test_html_page.html": "{BIN_DIR}/test/html/minify_test_html_page.min.html",
        "test/html/dep.txt": "test/html/dep.txt",
    },
}

assert_label_providers(
    ":minify_test_html_page",
    minify_test_html_page_providers,
)

minify_html(
    name = "minify_expected_test_html_page",
    src = "test_html_page_expected_unminified.html",
)

assert_files_equal(":minify_expected_test_html_page", ":minify_test_html_page")

validate_html(
    name = "validate_minify_test_html_page",
    src = ":minify_test_html_page",
)

minify_html(
    name = "test_minify_html",
    src = "test.html",
)

assert_files_equal("expected.html", ":test_minify_html")

assert_valid_type(":test_minify_html", "html")

assert_descending_sizes([
    "test.html",
    ":test_minify_html",
])

assert_label_providers(
    ":test_minify_html",
    {
        "actions": [None],
        "resources": [
            "{BIN_DIR}/test/html/test_minify_html.min.html",
        ],
        "source_map": {
            "test/html/test.html": "{BIN_DIR}/test/html/test_minify_html.min.html",
        },
    },
)

inject_html(
    name = "append_inject_html_test",
    inner_html = "inner.html",
    insertion_mode = "append",
    outer_html = "outer-full.html",
    query_selector = "html > body div#inner-holder",
)

assert_files_equal("expected-inject-html-append.html", ":append_inject_html_test")

assert_valid_type(":append_inject_html_test", "html")

assert_label_providers(
    ":append_inject_html_test",
    {
        "actions": [None],
        "css_resources": [],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [
            "{BIN_DIR}/test/html/append_inject_html_test.html",
        ],
        "source_map": {},
    },
)

inject_html(
    name = "prepend_inject_html_test",
    inner_html = "inner.html",
    insertion_mode = "prepend",
    outer_html = "outer-full.html",
    query_selector = "html > body div#inner-holder",
)

assert_files_equal("expected-inject-html-prepend.html", ":prepend_inject_html_test")

assert_valid_type(":prepend_inject_html_test", "html")

assert_label_providers(
    ":prepend_inject_html_test",
    {
        "actions": [None],
        "css_resources": [],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [
            "{BIN_DIR}/test/html/prepend_inject_html_test.html",
        ],
        "source_map": {},
    },
)

inject_html(
    name = "replace_contents_inject_html_test",
    inner_html = "inner.html",
    insertion_mode = "replace_contents",
    outer_html = "outer-full.html",
    query_selector = "html > body div#inner-holder",
)

assert_files_equal("expected-inject-html-replace-contents.html", ":replace_contents_inject_html_test")

assert_valid_type(":replace_contents_inject_html_test", "html")

assert_label_providers(
    ":replace_contents_inject_html_test",
    {
        "actions": [None],
        "css_resources": [],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [
            "{BIN_DIR}/test/html/replace_contents_inject_html_test.html",
        ],
        "source_map": {},
    },
)

inject_html(
    name = "replace_node_inject_html_test",
    inner_html = "inner.html",
    insertion_mode = "replace_node",
    outer_html = "outer-full.html",
    query_selector = "html > body div#inner-holder",
)

assert_files_equal("expected-inject-html-replace-node.html", ":replace_node_inject_html_test")

assert_valid_type(":replace_node_inject_html_test", "html")

assert_label_providers(
    ":replace_node_inject_html_test",
    {
        "actions": [None],
        "css_resources": [],
        "deferred_js_resources": [],
        "js_resources": [],
        "resources": [
            "{BIN_DIR}/test/html/replace_node_inject_html_test.html",
        ],
        "source_map": {},
    },
)

inject_html_inherited_providers_test_providers = dict(minify_test_html_page_providers)

inject_html_inherited_providers_test_providers["resources"].remove("{BIN_DIR}/test/html/minify_test_html_page.min.html")

# For an unexplained reason, these lists are reversed
inject_html_inherited_providers_test_providers["resources"] = reverse(inject_html_inherited_providers_test_providers["resources"])

inject_html_inherited_providers_test_providers["source_map"] = reverse(inject_html_inherited_providers_test_providers["source_map"])

inject_html(
    name = "inject_html_outer_inherited_providers_test",
    inner_html = "inner.html",
    insertion_mode = "replace_node",
    outer_html = ":minify_test_html_page",
    query_selector = "html",
)

assert_files_equal("expected-inject-html-outer-inherited-providers-test.html", ":inject_html_outer_inherited_providers_test")

outer_inherited_providers = dict(inject_html_inherited_providers_test_providers)

outer_inherited_providers["js_resources"] = reverse(outer_inherited_providers["js_resources"])

outer_inherited_providers["resources"] = (
    ["{BIN_DIR}/test/html/inject_html_outer_inherited_providers_test.html"] +
    outer_inherited_providers["resources"]
)

assert_label_providers(
    ":inject_html_outer_inherited_providers_test",
    outer_inherited_providers,
)

inject_html(
    name = "inject_html_inner_inherited_providers_test",
    inner_html = ":minify_test_html_page",
    insertion_mode = "replace_node",
    outer_html = "inner.html",
    query_selector = "span",
)

assert_files_equal(":minify_test_html_page", ":inject_html_inner_inherited_providers_test")

inner_inherited_providers = dict(inject_html_inherited_providers_test_providers)

inner_inherited_providers["resources"] = (
    ["{BIN_DIR}/test/html/inject_html_inner_inherited_providers_test.html"] +
    inner_inherited_providers["resources"]
)

# An even stranger thing occurs here where the the source_map and js_resources need to be reversed again
inner_inherited_providers["source_map"] = reverse(inner_inherited_providers["source_map"])
inner_inherited_providers["js_resources"] = reverse(inner_inherited_providers["js_resources"])

assert_label_providers(
    ":inject_html_inner_inherited_providers_test",
    inner_inherited_providers,
)

validate_html(
    name = "validate_html_disable_fail_on_warning",
    src = "warnings.html",
    fail_on_warning = False,
)

validate_html(
    name = "validate_html_filter_pattern",
    src = "warnings.html",
    filter_pattern = "The \\u201ctype\\u201d attribute is unnecessary for JavaScript resources\\.",
)

validate_html(
    name = "validate_html_filter_file",
    src = "warnings.html",
    filter_file = "validator.filter",
)
