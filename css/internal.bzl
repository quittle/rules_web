# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load(
    "//:internal.bzl",
    "transitive_resources_",
)

def web_internal_minify_css_impl(ctx):
    source_paths = [source.path for source in ctx.files.srcs]

    ctx.actions.run(
        mnemonic = "MinifyCSS",
        arguments = source_paths +
                    [
                        "--type",
                        "css",
                        "-o",
                        ctx.outputs.min_css_file.path,
                    ],
        inputs = ctx.files.srcs,
        tools = [ctx.executable._yui_binary],
        executable = ctx.executable._yui_binary,
        outputs = [ctx.outputs.min_css_file],
    )

    ret = struct(
        css_resources = depset([ctx.outputs.min_css_file]),
    )

    for resource in ctx.attr.srcs:
        ret = transitive_resources_(ret, resource, ["css_resources"])

    return ret
