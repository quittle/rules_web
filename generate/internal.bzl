# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//:internal.bzl",
    "transitive_resources_",
)

def web_internal_generate_variables(ctx):
    out_files = []
    if ctx.outputs.out_js:
        out_files.append(ctx.outputs.out_js)
    if ctx.outputs.out_css:
        out_files.append(ctx.outputs.out_css)
    if ctx.outputs.out_scss:
        out_files.append(ctx.outputs.out_scss)

    if len(out_files) == 0:
        fail("Need at least one output file")

    ctx.action(
        mnemonic = "GeneratingVariableFiles",
        arguments =
            [
                "--config", ctx.file.config.path,
            ] +
            ([ "--js-out", ctx.outputs.out_js.path ] if ctx.outputs.out_js else []) +
            ([ "--css-out", ctx.outputs.out_css.path ] if ctx.outputs.out_css else []) +
            ([ "--scss-out", ctx.outputs.out_scss.path ] if ctx.outputs.out_scss else []),
        inputs = [ ctx.executable._generate_variables_script, ctx.file.config ],
        executable = ctx.executable._generate_variables_script,
        outputs = out_files,
    )

    ret = struct(
        css_resources = set([ctx.outputs.out_css.path ]) if ctx.outputs.out_css else set(),
        js_resources = set([ctx.outputs.out_js.path ]) if ctx.outputs.out_js else set(),
        resources = set([ctx.outputs.out_scss.path ]) if ctx.outputs.out_scss else set(),
    )

    ret = transitive_resources_(ret, ctx.file.config)

    return ret
