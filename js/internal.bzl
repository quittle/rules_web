# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//:internal.bzl",
    "optional_arg_",
)

def web_internal_minify_js_impl(ctx):
    source_paths = [ source.path for source in ctx.files.srcs ]

    ctx.action(
        mnemonic = "MinifyJavascript",
        arguments = source_paths +
            [
                "--type", "js",
                "-o", ctx.outputs.min_js_file.path,
            ],
        inputs = [ ctx.executable._yui_binary ] + ctx.files.srcs,
        executable = ctx.executable._yui_binary,
        outputs = [ ctx.outputs.min_js_file ],
    )

    return struct(
        js_resources = set([ ctx.outputs.min_js_file ]),
    )

def web_internal_closure_compile_impl(ctx):
    source_paths = [ source.path for source in ctx.files.srcs ]
    extern_paths = [ extern.path for extern in ctx.files.externs ]

    ctx.action(
        mnemonic = "ClosureCompilingJavascript",
        arguments = source_paths +
            [
                "--js_output_file", ctx.outputs.compiled_js.path,
                "--compilation_level", ctx.attr.compilation_level,
                "--jscomp_error", "*",
                "--warning_level", ctx.attr.warning_level,
                "--language_in", "ECMASCRIPT6_STRICT",
                "--language_out", "ECMASCRIPT5",
            ] +
            optional_arg_("--externs", extern_paths) +
            ctx.attr.extra_args,
        inputs = ctx.files.srcs + ctx.files.externs,
        executable = ctx.executable._closure_compiler,
        outputs = [ ctx.outputs.compiled_js ],
    )

    return struct(
        js_resources = set(
            [ ctx.outputs.compiled_js ] +
            ctx.files.externs
        ),
    )
