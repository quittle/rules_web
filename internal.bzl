# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

# Helper function for copying a file from one location to another
# ctx - ctx - The context to use
# file_copy_script - executable - The file_copy executable
# source_file - File - The file to copy
# destination_file - File - The file to copy it out to
def _copy(ctx, file_copy_script, source_file, destination_file):
    if (type(ctx) != "ctx"):
        fail("ctx was not a context")
    if (type(file_copy_script) != "File"):
        fail("file_copy_script was not a file")
    if (type(source_file) != "File"):
        fail("source_file was not a file")
    if (type(destination_file) != "File"):
        fail("destination_file was not a file")

    ctx.action(
        mnemonic = "CopyFile",
        arguments = [
            "--source", source_file.path,
            "--destination", destination_file.path,
        ],
        inputs = [ file_copy_script, source_file ],
        executable = file_copy_script,
        outputs = [ destination_file ],
    )


# Helper function to define a label for a python script
# label - string - The label of the script
def web_internal_python_script_label(label):
    if (type(label) != "string"):
        fail("label was not a string")

    return attr.label(
        default = Label(label),
        executable = True,
        cfg = "host",
        allow_files = True,

        # single_file cannot be used while py_binary produces multiple
        # files, the binary of which is not selectable as a specific target
        # the way java_binary is
        #single_file = True,
    )

# Helper function to define a label for a tool
# label - string - The label of the tool
def web_internal_tool_label(label):
    if (type(label) != "string"):
        fail("label was not a string")

    return attr.label(
        default = Label(label),
        executable = True,
        cfg = "host",
        single_file = True,
        allow_files = True,
    )

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

def web_internal_ttf_to_woff2(ctx):
    name = ctx.label.name

    # The tool unfortunately does not take the output path as an argument and simply creates a new
    # file next to the old one with a new extension
    copied_source = ctx.new_file(ctx.outputs.out_woff2.basename.replace(".woff2", ".ttf"))

    _copy(ctx, ctx.executable._file_copy, ctx.file.ttf, copied_source)

    ctx.action(
        mnemonic = "GenerateWOFF2",
        arguments = [
            copied_source.path,
        ],
        inputs = [ copied_source ],
        executable = ctx.executable._ttf2woff2,
        outputs = [ ctx.outputs.out_woff2 ],
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

def web_internal_rename_zip_paths(ctx):
    if len(ctx.files.path_map_labels_in) != len(ctx.attr.path_map_labels_out):
        fail("path_map_labels_in must be the same size as path_map_labels_out")


    path_map = { key: value for key, value in ctx.attr.path_map.items() }
    path_map.update({
            in_label.path: out_path
                    for in_label in ctx.files.path_map_labels_in
                            for out_path in ctx.attr.path_map_labels_out })

    path_map_list = [
        value
            for key in path_map
                for value in (key, path_map[key]) ]

    ctx.action(
        mnemonic = "RenameZipPaths",
        arguments = [
                "--in-zip", ctx.file.source_zip.path,
                "--out-zip", ctx.outputs.out_zip.path,
            ] +
            [ "--path-map" ] + path_map_list,
        inputs = [
            ctx.executable._rename_zip_paths_script,
            ctx.file.source_zip,
        ],
        executable = ctx.executable._rename_zip_paths_script,
        outputs = [ ctx.outputs.out_zip ],
    )

def web_internal_generate_jinja_file(ctx, template, config, out_file):
    if (type(ctx) != "ctx"):
        fail("ctx was not a context")
    if (type(template) != "File"):
        fail("template was not a File")
    if (type(config) != "dict"):
        fail("config was not a dictionary")
    if (type(out_file) != "File"):
        fail("out_file was not a File")

    ctx.action(
        mnemonic = "GeneratingFileFromJinjaTemplate",
        arguments = [
            "--template", template.path,
            "--config", str(config),
            "--out-file", out_file.path,
        ],
        inputs = [ template ],
        executable = ctx.executable._generate_jinja_file,
        outputs = [ out_file ],
    )


def web_internal_generate_zip_server_python_file(ctx):
    config = {
        "port": ctx.attr.port,
        "zip": ctx.file.zip.basename,
    }

    web_internal_generate_jinja_file(ctx, ctx.file._template, config, ctx.outputs.out_file)

def web_internal_generate_deploy_site_zip_s3_script(ctx):
    ctx.action(
        mnemonic = "GeneratingS3DeployScript",
        arguments = [
            "--aws-access-key", ctx.attr.aws_access_key,
            "--aws-secret-key", ctx.attr.aws_secret_key,
            "--bucket", ctx.attr.bucket,
            "--deploy-executable", ctx.executable._s3_website_deploy.path,
            "--deployment-jinja-template", ctx.file._deploy_site_zip_to_s3_template.path,
            "--generated-file", ctx.outputs.generated_script.path,
            "--website-zip", ctx.file.zip.path,
        ],
        inputs = [
            ctx.file.zip,
            ctx.file._deploy_site_zip_to_s3_template,
            ctx.executable._s3_website_deploy,
            ctx.executable._s3_website_deploy_script_builder,
        ],
        outputs = [ ctx.outputs.generated_script ],
        executable = ctx.executable._s3_website_deploy_script_builder,
    )
