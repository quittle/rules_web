# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//:constants.bzl",
    "CSS_FILE_TYPE",
)

load("//:internal.bzl",
    "web_internal_tool_label",
)

load(":internal.bzl",
    "web_internal_minify_css_impl",
)

minify_css = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = CSS_FILE_TYPE,
            non_empty = True,
            mandatory = True,
        ),
        "_yui_binary": web_internal_tool_label("@yui_compressor//:yui_compressor"),
    },
    outputs = {
        "min_css_file": "%{name}.min.css",
    },
    implementation = web_internal_minify_css_impl,
)