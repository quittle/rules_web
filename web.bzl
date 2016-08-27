# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

CSS_FILE_TYPE = FileType([".css"])
HTML_FILE_TYPE = FileType([".html"])
JS_FILE_TYPE = FileType([".js"])
JSON_FILE_TYPE = FileType([".json"])

def _minify_css_impl(ctx):
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

minify_css = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = CSS_FILE_TYPE,
            non_empty = True,
            mandatory = True,
        ),
        "yui_binary": attr.label(
            default = Label("@yui_compressor//:yui_compressor_deploy.jar"),
            executable = True,
            single_file = True,
            allow_files = True,
        ),
    },
    outputs = {
        "min_css_file": "%{name}.min.css",
    },
    implementation = _minify_css_impl,
)

def _minify_js_impl(ctx):
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

minify_js = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = JS_FILE_TYPE,
            non_empty = True,
            mandatory = True,
        ),
        "yui_binary": attr.label(
            default = Label("@yui_compressor//:yui_compressor_deploy.jar"),
            executable = True,
            single_file = True,
            allow_files = True,
        ),
    },
    outputs = {
        "min_js_file": "%{name}.min.js",
    },
    implementation = _minify_js_impl,
)

def _html_page_impl(ctx):
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
            "--output", output_path,
        ] + [ "--favicons" ] + favicons,
        inputs =
            [
                ctx.executable._html_template_script,
                ctx.file.template,
                ctx.file.config
            ] +
            ctx.files.js_files +
            ctx.files.css_files +
            ctx.files.favicon_images,
        executable = ctx.executable._html_template_script,
        outputs = [ ctx.outputs.html_file ],
    )

html_page = rule(
    attrs = {
        "template": attr.label(
            default = Label("//:index.jinja2"),
            single_file = True,
            allow_files = True,
        ),
        "config": attr.label(
            single_file = True,
            mandatory = True,
            allow_files = JSON_FILE_TYPE,
        ),
        "js_files": attr.label_list(
            default = [],
            allow_files = JS_FILE_TYPE,
        ),
        "css_files": attr.label_list(
            default = [],
            allow_files = CSS_FILE_TYPE,
        ),
        "favicon_images": attr.label_list(
            allow_files = True,
        ),
        "favicon_sizes": attr.int_list(),
        "_html_template_script": attr.label(
            default = Label("//:html_template"),
            executable = True,
            allow_files = True,
            # single_file cannot be used while py_binary produces multiple
            # files, the binary of which is not selectable as a specific target
            # the way java_binary is
            # single_file = True,
        ),
    },
    outputs = {
        "html_file": "%{name}.html",
    },
    implementation = _html_page_impl,
)

def _favicon_image_generator(ctx):
    additional_args = []

    if ctx.attr.allow_upsizing:
        additional_args.append("--allow-upsizing")

    if ctx.attr.allow_stretching:
        additional_args.append("--allow-stretching")

    for size in ctx.attr.sizes:
        file = getattr(ctx.outputs, str(size))

        ctx.action(
            mnemonic = "GenerateFaviconSize",
            arguments = [
                "--source", ctx.file.image.path,
                "--width", str(size),
                "--height", str(size),
                "--output", file.path,
            ] + additional_args,
            inputs = [
                ctx.executable._resize_image,
                ctx.file.image,
            ],
            executable = ctx.executable._resize_image,
            outputs = [ file ],
        )

def _favicon_image_generator_outputs(generated_file_prefix, sizes):
    return {
            str(size):
            "favicon/{prefix}_{size}.png".format(prefix = generated_file_prefix, size = size)
                for size in sizes }

_favicon_image_generator_defaults = {
    "sizes": [ 16, 32 ],
    "generated_file_prefix": "favicon",
}

favicon_image_generator = rule(
    attrs = {
        "generated_file_prefix": attr.string(
            default = _favicon_image_generator_defaults["generated_file_prefix"],
        ),
        "image": attr.label(
            single_file = True,
            allow_files = True,
        ),
        "sizes": attr.int_list(
            default = _favicon_image_generator_defaults["sizes"],
            allow_empty = False,
        ),
        "allow_upsizing": attr.bool(
            default = False,
        ),
        "allow_stretching": attr.bool(
            default = False,
        ),
        "_resize_image": attr.label(
            default = Label("//:resize_image"),
            executable = True,
            allow_files = True,
            # single_file cannot be used while py_binary produces multiple
            # files, the binary of which is not selectable as a specific target
            # the way java_binary is
            # single_file = True,
        ),
    },
    outputs = _favicon_image_generator_outputs,
    implementation = _favicon_image_generator,
)

def build_html_page(name, html_page_args, favicon_image_generator_args):
    favicon_sizes = getattr(favicon_image_generator_args,
                            "sizes",
                            _favicon_image_generator_defaults["sizes"])
    favicon_prefix = getattr(favicon_image_generator_args,
                             "generated_file_prefix",
                             _favicon_image_generator_defaults["generated_file_prefix"])

    favicon_outputs = {
        int(key): value
            for key, value in
                _favicon_image_generator_outputs(favicon_prefix, favicon_sizes).items() }

    favicon_image_generator(name = name + "__favicon", **favicon_image_generator_args)
    html_page(
        name = name + "__html",
        favicon_sizes = favicon_outputs.keys(),
        favicon_images = favicon_outputs.values(),
        **html_page_args)
