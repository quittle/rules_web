# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load("@bazel_toolbox//labels:labels.bzl",
    "executable_label",
)

load("//:constants.bzl",
    "JS_FILE_TYPE",
)

load(":internal.bzl",
    "web_internal_closure_compile_impl",
    "web_internal_minify_js_impl",
    "web_internal_resource_map_impl",
)

resource_map = rule(
    attrs = {
        "constant_name": attr.string(
            mandatory = True,
        ),
        "deps": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        "_resource_map_script": executable_label(Label("//js:resource_map")),
    },
    outputs = {
        "resource_map": "resource_map/%{name}.js",
    },
    implementation = web_internal_resource_map_impl,
)

minify_js = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = JS_FILE_TYPE,
            non_empty = True,
            mandatory = True,
        ),
        "_yui_binary": executable_label("@yui_compressor//:yui_compressor"),
    },
    outputs = {
        "min_js_file": "minify_js/%{name}.min.js",
    },
    implementation = web_internal_minify_js_impl,
)

closure_compile = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = JS_FILE_TYPE,
            non_empty = True,
            mandatory = True,
        ),
        "externs": attr.label_list(
            allow_files = JS_FILE_TYPE,
        ),
        "compilation_level": attr.string(
            default = "SIMPLE",
            values = [
                "WHITESPACE_ONLY",
                "SIMPLE",
                "ADVANCED",
            ],
        ),
        "warning_level": attr.string(
            default = "VERBOSE",
            values = [
                "QUIET",
                "DEFAULT",
                "VERBOSE",
            ],
        ),
        "extra_args": attr.string_list(),
        "_closure_compiler": executable_label(Label("//js:closure_compiler")),
    },
    outputs = {
        "compiled_js": "closure_compile/%{name}.js",
    },
    implementation = web_internal_closure_compile_impl,
)
