# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//:internal.bzl",
    "optional_arg_",
    "transitive_resources_",
)

def web_internal_resource_map_impl(ctx):
    source_map = {}
    for dep in ctx.attr.deps:
        source_map += getattr(dep, "source_map", {})
        for file in dep.files:
            if file.is_source:
                source_map[file.short_path] = file

    path_map = {
        in_relative_path: out_file.path
            for in_relative_path, out_file in source_map.items()
    }

    ctx.action(
        mnemonic = "GeneratingResourceMapJS",
        arguments = [
            "--constant-name", ctx.attr.constant_name,
            "--path-map", str(path_map),
            "--output", ctx.outputs.resource_map.path,
        ],
        inputs = [ ctx.executable._resource_map_script ] + ctx.files.deps,
        executable = ctx.executable._resource_map_script,
        outputs = [ ctx.outputs.resource_map ],
    )

    ret = struct(
        js_resources = depset([ ctx.outputs.resource_map ]),
    )
    for dep in ctx.attr.deps:
        ret = transitive_resources_(ret, dep)
    return ret

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
        js_resources = depset([ ctx.outputs.min_js_file ]),
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
        js_resources = depset(
            [ ctx.outputs.compiled_js ] +
            ctx.files.externs
        ),
    )
