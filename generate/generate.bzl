# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load(
    "@bazel_toolbox//labels:labels.bzl",
    "executable_label",
)
load(
    ":internal.bzl",
    "web_internal_generate_variables",
)

generate_variables = rule(
    attrs = {
        "config": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "out_js": attr.output(),
        "out_css": attr.output(),
        "out_scss": attr.output(),
        "_generate_variables_script": executable_label(Label("//generate:generate_variables")),
    },
    output_to_genfiles = True,
    implementation = web_internal_generate_variables,
)
