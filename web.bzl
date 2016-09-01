# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load(":internal.bzl",
    "web_internal_minify_css_impl",
    "web_internal_minify_js_impl",
    "web_internal_minify_html_impl",
    "web_internal_html_page_impl",
    "web_internal_favicon_image_generator",
    "web_internal_zip_site",
    "web_internal_minify_site_zip",
)

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
        "_yui_binary": attr.label(
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
        "_yui_binary": attr.label(
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

minify_html = rule(
    attrs = {
        "src": attr.label(
            allow_files = HTML_FILE_TYPE,
            single_file = True,
            mandatory = True,
        ),
        "_http_compressor": attr.label(
            default = Label("//:html_compressor_deploy.jar"),
            executable = True,
            single_file = True,
            allow_files = True,
        ),
    },
    outputs = {
        "min_html_file": "%{name}.min.html",
    },
    implementation = web_internal_minify_html_impl,
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
        "deps": attr.label_list(),
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
        "image": attr.label(
            single_file = True,
            allow_files = True,
        ),
        "output_files": attr.output_list(
            allow_empty = False,
            mandatory = True,
        ),
        "output_sizes": attr.int_list(
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
    implementation = web_internal_favicon_image_generator,
    output_to_genfiles = True,
)

zip_site = rule(
    attrs = {
        "html_pages": attr.label_list(),
        "resources": attr.label_list(),
        "out_zip": attr.output(
            mandatory = True,
        ),
        "_zip_site_script": attr.label(
            default = Label("//:zip_site"),
            executable = True,
            allow_files = True,

            # single_file cannot be used while py_binary produces multiple
            # files, the binary of which is not selectable as a specific target
            # the way java_binary is
            # single_file = True,
        )
    },
    implementation = web_internal_zip_site,
)

minify_site_zip = rule(
    attrs = {
        "site_zip": attr.label(
            mandatory = True,
            allow_files = True,
            single_file = True,
        ),
        "root_files": attr.label_list(),
        "minified_zip": attr.output(
            mandatory = True,
        ),
        "_minify_site_zip_script": attr.label(
            default = Label("//:minify_site_zip"),
            executable = True,
            allow_files = True,

            # single_file cannot be used while py_binary produces multiple
            # files, the binary of which is not selectable as a specific target
            # the way java_binary is
            # single_file = True,
        ),
    },
    implementation = web_internal_minify_site_zip,
)