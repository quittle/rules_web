# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//:internal.bzl",
    "optional_arg_",
)

def _minify_png(ctx, pngtastic, in_png, out_png, iterations):
    if (type(ctx) != "ctx"):
        fail("ctx was not a context")
    if (type(pngtastic) != "File"):
        fail("pngtastic was not a File")
    if (type(in_png) != "File"):
        fail("in_png was not a File")
    if (type(out_png) != "File"):
        fail("out_png was not a File")
    if (type(iterations) != "int"):
        fail("iterations was not a int")

    ctx.action(
        mnemonic = "MinifyPNG",
        arguments = [
            "--input", in_png.path,
            "--output", out_png.path,
            "--iterations", str(iterations),
        ],
        inputs = [ in_png ],
        executable = pngtastic,
        outputs = [ out_png ],
    )

def web_internal_minify_png(ctx):
    _minify_png(
        ctx,
        ctx.executable._pngtastic,
        ctx.file.png,
        ctx.outputs.min_png,
        ctx.attr.iterations,
    )

    source_map = {}
    source_map[ctx.file.png.short_path] = ctx.outputs.min_png

    return struct(
        source_map = struct(**source_map),
        resources = set([ ctx.outputs.min_png ]),
    )

def web_internal_generate_ico(ctx):
    ctx.action(
        mnemonic = "GenerateICO",
        arguments = [
                "--source", ctx.file.source.path,
                "--output", ctx.outputs.ico.path,
            ] +
            [ "--sizes" ] + [ str(size) for size in ctx.attr.sizes ] +
            optional_arg_("--allow-upsizing", ctx.attr.allow_upsizing),
        inputs = [ ctx.file.source ],
        executable = ctx.executable._generate_ico,
        outputs = [ ctx.outputs.ico ],
    )

    return struct(
        resources = set([ ctx.outputs.ico ]),
    )

def web_internal_favicon_image_generator(ctx):
    if len(ctx.attr.output_files) != len(ctx.attr.output_sizes):
        fail("Same number of output files as sizes expected")

    additional_args = (
        optional_arg_("--allow-upsizing", ctx.attr.allow_upsizing) +
        optional_arg_("--allow-stretching", ctx.attr.allow_stretching)
    )

    outputs = []

    for size, out_file in zip(ctx.attr.output_sizes, ctx.outputs.output_files):
        unoptimized_png = ctx.new_file(out_file.short_path + "-unoptimized.png")

        ctx.action(
            mnemonic = "GenerateFaviconSize",
            arguments = [
                    "--source", ctx.file.image.path,
                    "--width", str(size),
                    "--height", str(size),
                    "--output", unoptimized_png.path,
                ] +
                additional_args,
            inputs = [
                ctx.executable._resize_image,
                ctx.file.image,
            ],
            executable = ctx.executable._resize_image,
            outputs = [ unoptimized_png ],
        )

        _minify_png(
            ctx,
            ctx.executable._pngtastic,
            unoptimized_png,
            out_file,
            ctx.attr.png_optimize_iterations,
        )

        outputs.append(out_file)

    return struct(
        resources = set(outputs),
    )