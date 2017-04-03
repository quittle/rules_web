# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load("@bazel_toolbox//labels:labels.bzl",
    "executable_label",
)

load("//:constants.bzl",
    "CSS_FILE_TYPE",
    "HTML_FILE_TYPE",
    "JS_FILE_TYPE",
    "JSON_FILE_TYPE",
)

load(":internal.bzl",
    "web_internal_html_page_impl",
    "web_internal_inject_html_impl",
    "web_internal_minify_html_impl",
)

html_page = rule(
    attrs = {
        "template": attr.label(
            default = Label("//html/templates:index.html.jinja2"),
            single_file = True,
            allow_files = True,
        ),
        "config": attr.label(
            single_file = True,
            mandatory = True,
            allow_files = JSON_FILE_TYPE,
        ),
        "body": attr.label(
            single_file = True,
            mandatory = True,
            allow_files = True,
        ),
        "deferred_js_files": attr.label_list(
            default = [],
            allow_files = JS_FILE_TYPE,
        ),
        "js_files": attr.label_list(
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
            single_file = True,
            allow_files = True,
            mandatory = True,
        ),
        "inner_html": attr.label(
            single_file = True,
            allow_files = True,
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
            allow_files = HTML_FILE_TYPE,
            single_file = True,
            mandatory = True,
        ),
        "_html_compressor": executable_label(Label("//html:html_compressor")),
    },
    outputs = {
        "min_html_file": "%{name}.min.html",
    },
    implementation = web_internal_minify_html_impl,
)
