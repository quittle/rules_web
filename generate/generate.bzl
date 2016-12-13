# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//:internal.bzl",
    "web_internal_python_script_label",
)

load(":internal.bzl",
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
        "_generate_variables_script": web_internal_python_script_label("//generate:generate_variables"),
    },
    implementation = web_internal_generate_variables,
)