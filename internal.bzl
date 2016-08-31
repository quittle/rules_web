# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

def web_internal_minify_css_impl(ctx):
    source_paths = [ source.path for source in ctx.files.srcs ]

    ctx.action(
        mnemonic = "MinifyCSS",
        arguments = source_paths +
            [
                "-o", ctx.outputs.min_css_file.path,
                "--type", "css"
            ],
        inputs = [ ctx.executable.yui_binary ] + ctx.files.srcs,
        executable = ctx.executable.yui_binary,
        outputs = [ ctx.outputs.min_css_file ],
    )

def web_internal_minify_js_impl(ctx):
    source_paths = [ source.path for source in ctx.files.srcs ]

    ctx.action(
        mnemonic = "MinifyJavaScript",
        arguments = source_paths +
            [
                "-o", ctx.outputs.min_js_file.path,
                "--type", "js"
            ],
        inputs = [ ctx.executable.yui_binary] + ctx.files.srcs,
        executable = ctx.executable.yui_binary,
        outputs = [ ctx.outputs.min_js_file ],
    )

def web_internal_html_page_impl(ctx):
    if len(ctx.attr.favicon_sizes) != len(ctx.files.favicon_images):
        fail("Favicon sizes list length does not match favicon images list length")

    template_path = ctx.file.template.path
    config_path = ctx.file.config.path
    favicons = [ value
        for size, favicon in zip(ctx.attr.favicon_sizes, ctx.files.favicon_images)
            for value in (str(size), favicon.path)
    ]
    output_path = ctx.outputs.html_file.path
    js_paths = [ js_file.path for js_file in ctx.files.js_files ]
    css_paths = [ css_file.path for css_file in ctx.files.css_files ]

    ctx.action(
        mnemonic = "GenerateHTMLPage",
        arguments = [
            "--template", template_path,
            "--config", config_path,
            "--body", ctx.file.body.path,
            "--output", output_path,
        ] + [ "--favicons" ] + favicons,
        inputs =
            [
                ctx.executable._html_template_script,
                ctx.file.template,
                ctx.file.config,
                ctx.file.body,
            ] +
            ctx.files.js_files +
            ctx.files.css_files +
            ctx.files.favicon_images,
        executable = ctx.executable._html_template_script,
        outputs = [ ctx.outputs.html_file ],
    )

def web_internal_favicon_image_generator(ctx):
    additional_args = []

    if len(ctx.attr.output_files) != len(ctx.attr.output_sizes):
        fail("Same number of output files as sizes expected")

    if ctx.attr.allow_upsizing:
        additional_args.append("--allow-upsizing")

    if ctx.attr.allow_stretching:
        additional_args.append("--allow-stretching")

    for size, out_file in zip(ctx.attr.output_sizes, ctx.outputs.output_files):
        ctx.action(
            mnemonic = "GenerateFaviconSize",
            arguments = [
                "--source", ctx.file.image.path,
                "--width", str(size),
                "--height", str(size),
                "--output", out_file.path,
            ] + additional_args,
            inputs = [
                ctx.executable._resize_image,
                ctx.file.image,
            ],
            executable = ctx.executable._resize_image,
            outputs = [ out_file ],
    )
