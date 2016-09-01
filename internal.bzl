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
        inputs = [ ctx.executable._yui_binary ] + ctx.files.srcs,
        executable = ctx.executable._yui_binary,
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
        inputs = [ ctx.executable._yui_binary ] + ctx.files.srcs,
        executable = ctx.executable._yui_binary,
        outputs = [ ctx.outputs.min_js_file ],
    )

def web_internal_minify_html_impl(ctx):
    print(ctx.executable._http_compressor)
    ctx.action(
        mnemonic = "MinifyHTML",
        arguments = [
            "--output", ctx.outputs.min_html_file.path,
            ctx.file.src.path
        ],
        inputs = [ ctx.executable._http_compressor, ctx.file.src ],
        executable = ctx.executable._http_compressor,
        outputs = [ ctx.outputs.min_html_file ],
    )

def web_internal_html_page_impl(ctx):
    if len(ctx.attr.favicon_sizes) != len(ctx.files.favicon_images):
        fail("Favicon sizes list length does not match favicon images list length")

    favicons = [ value
        for size, favicon in zip(ctx.attr.favicon_sizes, ctx.files.favicon_images)
            for value in (str(size), favicon.path)
    ]
    css_paths = [ css_file.path for css_file in ctx.files.css_files ]
    js_paths = [ js_file.path for js_file in ctx.files.js_files ]

    ctx.action(
        mnemonic = "GenerateHTMLPage",
        arguments = [
                "--template", ctx.file.template.path,
                "--config", ctx.file.config.path,
                "--body", ctx.file.body.path,
                "--output", ctx.outputs.html_file.path,
            ] +
            [ "--favicons" ] + favicons +
            [ "--css-files" ] + css_paths +
            [ "--js-files" ] + js_paths,
        inputs = [
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
    if len(ctx.attr.output_files) != len(ctx.attr.output_sizes):
        fail("Same number of output files as sizes expected")

    additional_args = []

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
                ] +
                additional_args,
            inputs = [
                ctx.executable._resize_image,
                ctx.file.image,
            ],
            executable = ctx.executable._resize_image,
            outputs = [ out_file ],
    )

def web_internal_zip_site(ctx):
    html_pages = [ page.path for page in ctx.files.html_pages ]
    resources = [ resource.path for resource in ctx.files.resources ]

    additional_args = []
    if len(html_pages) > 0:
        additional_args += [ "--html-pages" ] + html_pages
    if len(resources) > 0:
        additional_args += [ "--resources" ] + resources

    ctx.action(
        mnemonic = "ZipSite",
        arguments = [
                "--output", ctx.outputs.out_zip.path,
            ] +
            additional_args,
        inputs = [
                ctx.executable._zip_site_script,
            ] +
            ctx.files.resources +
            ctx.files.html_pages,
        executable = ctx.executable._zip_site_script,
        outputs = [ ctx.outputs.out_zip ]
    )

def web_internal_minify_site_zip(ctx):
    root_files = [ file.path for file in ctx.files.root_files ]

    additional_args = []
    if len(root_files) > 0:
        additional_args += [ "--root-files" ] + root_files

    ctx.action(
        mnemonic = "MinifySiteZip",
        arguments = [
                "--in-zip", ctx.file.site_zip.path,
                "--out-zip", ctx.outputs.minified_zip.path,
            ] + additional_args,
        inputs = [
                ctx.executable._minify_site_zip_script,
                ctx.file.site_zip,
            ] +
            ctx.files.root_files,
        executable = ctx.executable._minify_site_zip_script,
        outputs = [ ctx.outputs.minified_zip ],
    )
