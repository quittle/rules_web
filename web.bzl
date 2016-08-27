# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load(":internal.bzl",
    "web_internal_minify_css_impl",
    "web_internal_minify_js_impl",
    "web_internal_html_page_impl",
    "web_internal_favicon_image_generator",
    "web_internal_favicon_image_generator_defaults",
    "web_internal_favicon_image_generator_outputs")

CSS_FILE_TYPE = FileType([".css"])
HTML_FILE_TYPE = FileType([".html"])
JS_FILE_TYPE = FileType([".js"])
JSON_FILE_TYPE = FileType([".json"])

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
    implementation = web_internal_minify_css_impl,
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
    implementation = web_internal_minify_js_impl,
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
        "body": attr.label(
            single_file = True,
            mandatory = True,
            allow_files = True,
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
    implementation = web_internal_html_page_impl,
)

favicon_image_generator = rule(
    attrs = {
        "generated_file_prefix": attr.string(
            default = web_internal_favicon_image_generator_defaults["generated_file_prefix"],
        ),
        "image": attr.label(
            single_file = True,
            allow_files = True,
        ),
        "sizes": attr.int_list(
            default = web_internal_favicon_image_generator_defaults["sizes"],
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
    outputs = web_internal_favicon_image_generator_outputs,
    implementation = web_internal_favicon_image_generator,
)

def build_html_page(name, html_page_args, favicon_image_generator_args):
    favicon_sizes = getattr(favicon_image_generator_args,
                            "sizes",
                            web_internal_favicon_image_generator_defaults["sizes"])
    favicon_prefix = getattr(favicon_image_generator_args,
                             "generated_file_prefix",
                             web_internal_favicon_image_generator_defaults["generated_file_prefix"])

    favicon_outputs = {
        int(key): value
            for key, value in
                web_internal_favicon_image_generator_outputs(favicon_prefix, favicon_sizes).items() }

    favicon_image_generator(name = name + "__favicon", **favicon_image_generator_args)
    html_page(
        name = name + "__html",
        favicon_sizes = favicon_outputs.keys(),
        favicon_images = favicon_outputs.values(),
        **html_page_args)
