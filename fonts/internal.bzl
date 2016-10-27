# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//:internal.bzl",
    "copy_",
)

def _generate_ttx(ctx, in_ttf, out_ttx, ttx_executable):
    if (type(ctx) != "ctx"):
        fail("ctx was not a context")
    if (type(in_ttf) != "File"):
        fail("in_ttf was not a File")
    if (type(out_ttx) != "File"):
        fail("out_ttx was not a File")
    if (type(ttx_executable) != "File"):
        fail("ttx_executable was not a File")

    ctx.action(
        mnemonic = "GenerateTTX",
        arguments = [
            "-o", out_ttx.path,
            in_ttf.path,
        ],
        inputs = [ in_ttf ],
        executable = ttx_executable,
        outputs = [ out_ttx ],
    )

def web_internal_minify_ttf(ctx):
    name = ctx.label.name
    ttx = ctx.new_file("{name}__generated_ttx.ttx".format(name = name))
    min_ttx = ctx.new_file("{name}__generated_min_ttx.ttx".format(name = name))

    _generate_ttx(ctx, ctx.file.ttf, ttx, ctx.executable._ttx)

    # BUG: There is a currently a bug where running ttx via `ctx.action` but not directly or even
    # via `bazel run @font_tools//:ttx` causes ttx to act strangely. For instance, a minimal action
    # that runs `ttx --version` will show 3.0 instead of 3.1.2. This is mostly fine, however.
    ctx.action(
        mnemonic = "MinifyTTX",
        arguments = [
            "--in-ttx", ttx.path,
            "--out-ttx", min_ttx.path,
        ],
        inputs = [ ttx ],
        executable = ctx.executable._minify_ttx,
        outputs = [ min_ttx ],
    )

    ctx.action(
        mnemonic = "GenerateMinimalTTX",
        arguments = [
            "-o", ctx.outputs.out_ttf.path,
            min_ttx.path,
        ],
        inputs = [ min_ttx ],
        executable = ctx.executable._ttx,
        outputs = [ ctx.outputs.out_ttf ],
    )

    return struct(
        resources = set([ ctx.outputs.out_ttf ]),
    )

def web_internal_ttf_to_woff(ctx):
    name = ctx.label.name
    ttx = ctx.new_file("{name}__generated_ttx.ttx".format(name = name))

    _generate_ttx(ctx, ctx.file.ttf, ttx, ctx.executable._ttx)

    ctx.action(
        mnemonic = "GenerateWOFF",
        arguments = [
            "-o", ctx.outputs.out_woff.path,
            "--flavor", "woff",
            ttx.path,
        ],
        inputs = [ ttx ],
        executable = ctx.executable._ttx,
        outputs = [ ctx.outputs.out_woff ],
    )

    return struct(
        resources = set([ ctx.outputs.out_woff ]),
    )

def web_internal_ttf_to_woff2(ctx):
    # The tool unfortunately does not take the output path as an argument and simply creates a new
    # file next to the old one with a new extension
    copied_source = ctx.new_file(ctx.outputs.out_woff2.basename.replace(".woff2", ".ttf"))

    copy_(ctx, ctx.executable._file_copy, ctx.file.ttf, copied_source)

    ctx.action(
        mnemonic = "GenerateWOFF2",
        arguments = [
            copied_source.path,
        ],
        inputs = [ copied_source ],
        executable = ctx.executable._ttf2woff2,
        outputs = [ ctx.outputs.out_woff2 ],
    )

    return struct(
        resources = set([ ctx.outputs.out_woff2 ]),
    )

def web_internal_ttf_to_eot(ctx):
    ctx.action(
        mnemonic = "GenerateEOT",
        arguments = [
            ctx.file.ttf.path,
            ctx.outputs.out_eot.path,
        ],
        inputs = [ ctx.file.ttf ],
        executable = ctx.executable._ttf2eot,
        outputs = [ ctx.outputs.out_eot ],
    )

    return struct(
        resources = set([ ctx.outputs.out_eot ]),
    )

def web_internal_font_generator(ctx):
    # CSS src line for ie support
    single_source = ""
    # CSS  src line with multiple fonts for non-ie support. Contains tupples of (url, type)
    multi_source = []
    if ctx.file.eot != None:
        eot = ctx.file.eot.path
        single_source = "src: url('{eot}');".format(eot = eot)
        multi_source.append(("{eot}?#iefix".format(eot = eot), "embedded-opentype"))
    if ctx.file.ttf != None:
        ttf = ctx.file.ttf.path
        multi_source.append((ttf, "truetype"))
    if ctx.file.woff != None:
        woff = ctx.file.woff.path
        multi_source.append((woff, "woff"))
    if ctx.file.woff2 != None:
        woff2 = ctx.file.woff2.path
        multi_source.append((woff2, "woff2"))
    if ctx.file.svg != None:
        svg = ctx.file.svg.path
        multi_source.append((
                "{svg}#{name}-{weight}-{style}".format( # Must be unique per variant
                        svg = svg,
                        name = ctx.attr.name,
                        weight = ctx.attr.weight,
                        style = ctx.attr.style),
                "svg"))

    multi_source = [
            "url('{path}') format('{type}')".format(path=path,type=type)
                    for (path, type) in multi_source ]
    if len(multi_source) > 0:
        multi_source = "src: {formats};".format(formats = ",".join(multi_source))

    content = """
                /* AUTO-GENERATED FILE. DO NOT EDIT */

                @font-face {{
                    font-family: '{name}';
                    {single_source}
                    {multi_source}
                    font-weight: {weight};
                    font-style: {style};
                }}
            """.format(
                name = ctx.attr.font_name,
                single_source = single_source,
                multi_source = multi_source,
                weight = ctx.attr.weight,
                style = ctx.attr.style,
            )

    ctx.file_action(
        output = ctx.outputs.out_css,
        content = content
    )

    return struct(
        resources = set(
            [ file for file in
                [
                    ctx.file.eot,
                    ctx.file.ttf,
                    ctx.file.woff,
                    ctx.file.woff2,
                    ctx.file.svg,
                ] if file != None ]
        ),
        css_resources = set([
            ctx.outputs.out_css,
        ]),
    )
