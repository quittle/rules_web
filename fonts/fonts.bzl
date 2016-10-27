# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load(":internal.bzl",
    "web_internal_minify_ttf",
    "web_internal_ttf_to_woff",
    "web_internal_ttf_to_woff2",
    "web_internal_ttf_to_eot",
    "web_internal_font_generator",
)

load("//:internal.bzl",
    "web_internal_python_script_label",
    "web_internal_tool_label",
)

minify_ttf = rule(
    attrs = {
        "ttf": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "_ttx": web_internal_python_script_label("@font_tools//:ttx"),
        "_minify_ttx": web_internal_python_script_label("//fonts:minify_ttx"),
    },
    implementation = web_internal_minify_ttf,
    output_to_genfiles = True,
    outputs = {
        "out_ttf": "%{name}__minified.ttf",
    },
)

ttf_to_woff = rule(
    attrs = {
        "ttf": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "_ttx": web_internal_python_script_label("@font_tools//:ttx"),
    },
    implementation = web_internal_ttf_to_woff,
    output_to_genfiles = True,
    outputs = {
        "out_woff": "%{name}__generated.woff",
    },
)

ttf_to_woff2 = rule(
    attrs = {
        "ttf": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "_ttf2woff2": web_internal_tool_label("@woff2//:ttf2woff2"),
        "_file_copy": web_internal_python_script_label("//:file_copy"),
    },
    implementation = web_internal_ttf_to_woff2,
    output_to_genfiles = True,
    outputs = {
        "out_woff2": "%{name}__generated.woff2",
    },
)

ttf_to_eot = rule(
    attrs = {
        "ttf": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "_ttf2eot": web_internal_tool_label("@ttf2eot//:ttf2eot"),
    },
    implementation = web_internal_ttf_to_eot,
    output_to_genfiles = True,
    outputs = {
        "out_eot": "%{name}__generated.eot",
    },
)

font_generator = rule(
    attrs = {
        "font_name": attr.string(
            mandatory = True,
        ),
        "eot": attr.label(
            allow_files = True,
            single_file = True,
        ),
        "ttf": attr.label(
            allow_files = True,
            single_file = True,
        ),
        "woff": attr.label(
            allow_files = True,
            single_file = True,
        ),
        "woff2": attr.label(
            allow_files = True,
            single_file = True,
        ),
        "svg": attr.label(
            allow_files = True,
            single_file = True,
        ),
        "weight": attr.string(
            default = "normal",
            values = [
                100,
                200,
                300,
                400,
                500,
                600,
                700,
                800,
                900,
                "ligher",
                "normal",
                "bold",
                "bolder",
            ],
        ),
        "style": attr.string(
            default = "normal",
            values = [
                "normal",
                "italic",
            ],
        ),
    },
    implementation = web_internal_font_generator,
    output_to_genfiles = True,
    outputs = {
        "out_css": "%{name}__generated.css"
    },
)
