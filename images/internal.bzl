# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load(
    "@bazel_toolbox//collections:collections.bzl",
    "merge_dicts",
)
load(
    "//:internal.bzl",
    "optional_arg_",
)

def _minify_png(ctx, pngtastic, in_png, out_png):
    if (type(ctx) != "ctx"):
        fail("ctx was not a context")
    if (type(pngtastic) != "File"):
        fail("pngtastic was not a File")
    if (type(in_png) != "File"):
        fail("in_png was not a File")
    if (type(out_png) != "File"):
        fail("out_png was not a File")

    ctx.actions.run(
        mnemonic = "MinifyPNG",
        arguments = [
            "--input",
            in_png.path,
            "--output",
            out_png.path,
        ],
        inputs = [in_png],
        executable = pngtastic,
        outputs = [out_png],
    )

def web_internal_crop_image(ctx):
    output = ctx.outputs.cropped_image

    ctx.actions.run(
        mnemonic = "CroppingImage",
        arguments = [
            "--source",
            ctx.file.image.path,
            "--width",
            ctx.attr.width,
            "--height",
            ctx.attr.height,
            "--x-offset",
            ctx.attr.x_offset,
            "--y-offset",
            ctx.attr.y_offset,
            "--output",
            output.path,
        ],
        inputs = [
            ctx.file.image,
        ],
        executable = ctx.executable._crop_image,
        outputs = [output],
    )

    source_map = {ctx.file.image.short_path: output} if ctx.attr.map_source else {}

    return struct(
        resources = depset([output]),
        source_map = source_map,
    )

def web_internal_minify_png(ctx):
    _minify_png(
        ctx,
        ctx.executable._pngtastic,
        ctx.file.png,
        ctx.outputs.min_png,
    )

    source_map = {}
    source_map[ctx.file.png.short_path] = ctx.outputs.min_png
    return struct(
        source_map = source_map,
        resources = depset([ctx.outputs.min_png]),
    )

def web_internal_generate_ico(ctx):
    ctx.actions.run(
        mnemonic = "GenerateICO",
        arguments = [
                        "--source",
                        ctx.file.source.path,
                        "--output",
                        ctx.outputs.ico.path,
                    ] +
                    ["--sizes"] + [str(size) for size in ctx.attr.sizes] +
                    optional_arg_("--allow-upsizing", ctx.attr.allow_upsizing),
        inputs = [ctx.file.source],
        executable = ctx.executable._generate_ico,
        outputs = [ctx.outputs.ico],
    )

    return struct(
        resources = depset([ctx.outputs.ico]),
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
        unoptimized_png = ctx.actions.declare_file(out_file.short_path + "-unoptimized.png")

        ctx.actions.run(
            mnemonic = "GenerateFaviconSize",
            arguments = [
                            "--source",
                            ctx.file.image.path,
                            "--width",
                            str(size),
                            "--height",
                            str(size),
                            "--output",
                            unoptimized_png.path,
                        ] +
                        additional_args,
            inputs = [
                ctx.file.image,
            ],
            tools = [
                ctx.executable._resize_image,
            ],
            executable = ctx.executable._resize_image,
            outputs = [unoptimized_png],
        )

        _minify_png(
            ctx,
            ctx.executable._pngtastic,
            unoptimized_png,
            out_file,
        )

        outputs.append(out_file)

    return struct(
        resources = depset(outputs),
    )

def web_internal_resize_image(ctx):
    additional_args = None

    if (ctx.attr.width != -1 or ctx.attr.height != -1) and ctx.attr.scale == "":
        additional_args = []
        if ctx.attr.width != -1:
            additional_args += ["--width", str(ctx.attr.width)]
        if ctx.attr.height != -1:
            additional_args += ["--height", str(ctx.attr.height)]
    elif ctx.attr.width == -1 and ctx.attr.height == -1 and ctx.attr.scale != "":
        additional_args = ["--scale", ctx.attr.scale]
    else:
        fail("Either width and height need to be set or just scale")

    output = ctx.outputs.resized_image

    ctx.actions.run(
        mnemonic = "ResizingImage",
        arguments = [
            "--source",
            ctx.file.image.path,
            "--output",
            output.path,
            "--allow-upsizing",
            "--allow-stretching",
        ] + additional_args,
        inputs = [
            ctx.file.image,
        ],
        executable = ctx.executable._resize_image,
        outputs = [output],
    )

    source_map = getattr(ctx.attr.image, "source_map", {})

    source_map = merge_dicts(source_map, {ctx.file.image.short_path: output} if ctx.attr.map_source else {})

    for key, value in source_map.items():
        if value == ctx.file.image:
            source_map[key] = output

    return struct(
        resources = depset([output]),
        source_map = source_map,
    )
