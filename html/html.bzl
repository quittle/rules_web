# Copyright (c) 2016-2018 Dustin Toff
# Licensed under Apache License v2.0

load(
    "@bazel_toolbox//labels:labels.bzl",
    "executable_label",
)
load(
    "//:constants.bzl",
    "CSS_FILE_TYPE",
    "HTML_FILE_TYPE",
    "JSON_FILE_TYPE",
    "JS_FILE_TYPE",
)
load(
    ":internal.bzl",
    "web_internal_html_page_impl",
    "web_internal_inject_html_impl",
    "web_internal_minify_html_impl",
    "web_internal_validate_html_impl",
)

html_page = rule(
    attrs = {
        "template": attr.label(
            default = Label("//html/templates:index.html.jinja2"),
            allow_single_file = True,
        ),
        "config": attr.label(
            allow_single_file = JSON_FILE_TYPE,
            mandatory = True,
        ),
        "body": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "deferred_js_files": attr.label_list(
            default = [],
            allow_files = JS_FILE_TYPE,
        ),
        "js_files": attr.label_list(
            default = [],
            allow_files = JS_FILE_TYPE,
        ),
        "inline_js_files": attr.label_list(
            default = [],
            allow_files = JS_FILE_TYPE,
        ),
        "css_files": attr.label_list(
            default = [],
            allow_files = CSS_FILE_TYPE,
        ),
        "favicon_images": attr.label_list(
            allow_files = True,
        ),
        "favicon_sizes": attr.int_list(),
        "deps": attr.label_list(
            allow_files = True,
        ),
        "_html_template_script": executable_label(Label("//html:html_template")),
    },
    outputs = {
        "html_file": "%{name}.html",
    },
    implementation = web_internal_html_page_impl,
)

inject_html = rule(
    attrs = {
        "outer_html": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "inner_html": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "query_selector": attr.string(
            mandatory = True,
        ),
        "insertion_mode": attr.string(
            default = "replace_contents",
            values = [
                "append",
                "prepend",
                "replace_contents",
                "replace_node",
            ],
        ),
        "_inject_html_script": executable_label(Label("//html:inject_html")),
    },
    outputs = {
        "html_file": "%{name}.html",
    },
    implementation = web_internal_inject_html_impl,
)

minify_html = rule(
    attrs = {
        "src": attr.label(
            allow_single_file = HTML_FILE_TYPE,
            mandatory = True,
        ),
        "_html_compressor": executable_label(Label("//html:html_compressor")),
    },
    outputs = {
        "min_html_file": "%{name}.min.html",
    },
    implementation = web_internal_minify_html_impl,
)

validate_html = rule(
    attrs = {
        "src": attr.label(
            allow_single_file = HTML_FILE_TYPE,
            mandatory = True,
        ),
        "fail_on_warning": attr.bool(
            default = True,
        ),
        "filter_file": attr.label(
            allow_single_file = True,
        ),
        "filter_pattern": attr.string(),
        "_wrapped_w3c_validator": executable_label(Label("//html:wrapped_nu_validator")),
    },
    implementation = web_internal_validate_html_impl,
    outputs = {
        "stamp_file": "%{name}.stamp",
    },
)
