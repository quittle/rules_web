# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//:constants.bzl",
    "JS_FILE_TYPE",
)

load("//:internal.bzl",
    "web_internal_tool_label",
)

load(":internal.bzl",
    "web_internal_closure_compile_impl",
    "web_internal_minify_js_impl",
)

minify_js = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = JS_FILE_TYPE,
            non_empty = True,
            mandatory = True,
        ),
        "_yui_binary": web_internal_tool_label("@yui_compressor//:yui_compressor_deploy.jar"),
    },
    outputs = {
        "min_js_file": "%{name}.min.js",
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
        "_closure_compiler": web_internal_tool_label("//js:closure_compiler_deploy.jar"),
    },
    outputs = {
        "compiled_js": "%{name}.js",
    },
    implementation = web_internal_closure_compile_impl,
)
