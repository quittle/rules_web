# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load(
    "@bazel_toolbox//labels:labels.bzl",
    "executable_label",
)
load(
    "//:constants.bzl",
    "CSS_FILE_TYPE",
)
load(
    ":internal.bzl",
    "web_internal_minify_css_impl",
)

minify_css = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = CSS_FILE_TYPE,
            allow_empty = False,
            mandatory = True,
        ),
        "_yui_binary": executable_label(Label("//:yui_compressor")),
    },
    outputs = {
        "min_css_file": "%{name}.min.css",
    },
    implementation = web_internal_minify_css_impl,
)
