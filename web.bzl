# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load(":internal.bzl",
    "web_internal_python_script_label",
    "web_internal_tool_label",
    "web_internal_minify_css_impl",
    "web_internal_minify_js_impl",
    "web_internal_closure_compile_impl",
    "web_internal_minify_html_impl",
    "web_internal_html_page_impl",
    "web_internal_minify_png",
    "web_internal_generate_ico",
    "web_internal_favicon_image_generator",
    "web_internal_minify_ttf",
    "web_internal_ttf_to_woff",
    "web_internal_ttf_to_woff2",
    "web_internal_ttf_to_eot",
    "web_internal_font_generator",
    "web_internal_zip_site",
    "web_internal_minify_site_zip",
    "web_internal_rename_zip_paths",
    "web_internal_generate_zip_server_python_file",
    "web_internal_generate_deploy_site_zip_s3_script",
)

CSS_FILE_TYPE = FileType([".css"])
HTML_FILE_TYPE = FileType([".html"])
JS_FILE_TYPE = FileType([".js"])
JSON_FILE_TYPE = FileType([".json"])

DEFAULT_PNG_ITERATIONS = 64

minify_css = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = CSS_FILE_TYPE,
            non_empty = True,
            mandatory = True,
        ),
        "_yui_binary": web_internal_tool_label("@yui_compressor//:yui_compressor_deploy.jar"),
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
        "_yui_binary": web_internal_tool_label("@yui_compressor//:yui_compressor_deploy.jar"),
    },
    outputs = {
        "min_js_file": "%{name}.min.js",
    },
    implementation = web_internal_minify_js_impl,
)

closure_compile = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = JS_FILE_TYPE,
            non_empty = True,
            mandatory = True,
        ),
        "externs": attr.label_list(
            allow_files = JS_FILE_TYPE,
        ),
        "compilation_level": attr.string(
            default = "SIMPLE",
            values = [
                "WHITESPACE_ONLY",
                "SIMPLE",
                "ADVANCED",
            ],
        ),
        "warning_level": attr.string(
            default = "VERBOSE",
            values = [
                "QUIET",
                "DEFAULT",
                "VERBOSE",
            ],
        ),
        "extra_args": attr.string_list(),
        "_closure_compiler": web_internal_tool_label("//:closure_compiler_deploy.jar"),
    },
    outputs = {
        "compiled_js": "%{name}.js",
    },
    implementation = web_internal_closure_compile_impl,
)

minify_html = rule(
    attrs = {
        "src": attr.label(
            allow_files = HTML_FILE_TYPE,
            single_file = True,
            mandatory = True,
        ),
        "_html_compressor": web_internal_tool_label("//:html_compressor_deploy.jar"),
    },
    outputs = {
        "min_html_file": "%{name}.min.html",
    },
    implementation = web_internal_minify_html_impl,
)

html_page = rule(
    attrs = {
        "template": attr.label(
            default = Label("//templates:index.html.jinja2"),
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
        "deferred_js_files": attr.label_list(
            default = [],
            allow_files = JS_FILE_TYPE,
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
        "_html_template_script": web_internal_python_script_label("//:html_template"),
    },
    outputs = {
        "html_file": "%{name}.html",
    },
    implementation = web_internal_html_page_impl,
)

minify_png = rule(
    attrs = {
        "png": attr.label(
            single_file = True,
            allow_files = True,
            mandatory = True,
        ),
        "iterations": attr.int(
            default = DEFAULT_PNG_ITERATIONS,
        ),
        "_pngtastic": web_internal_tool_label("//:simplified_pngtastic_deploy.jar"),
    },
    outputs = {
        "min_png": "minified_png/%{name}.png",
    },
    implementation = web_internal_minify_png,
)

# BUG: This doesn't work as PIL does not support writing out ICO files
_generate_ico = rule(
    attrs = {
        "source": attr.label(
            single_file = True,
            allow_files = True,
            mandatory = True,
        ),
        "sizes": attr.int_list(
            mandatory = True,
            allow_empty = False,
        ),
        "allow_upsizing": attr.bool(
            default = False,
        ),
        "_generate_ico": web_internal_python_script_label("//:generate_ico"),
    },
    outputs = {
        # Due to limitations of pngtastic, we will create an intermediate file without the
        # ".min.png" suffix as well and want it to have a readable name.
        "ico": "%{name}.ico",
    },
    implementation = web_internal_generate_ico,
    output_to_genfiles = True,
)

favicon_image_generator = rule(
    attrs = {
        "image": attr.label(
            single_file = True,
            allow_files = True,
            mandatory = True,
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
        "png_optimize_iterations": attr.int(
            default = DEFAULT_PNG_ITERATIONS,
        ),
        "_resize_image": web_internal_python_script_label("//:resize_image"),
        "_pngtastic": web_internal_tool_label("//:simplified_pngtastic_deploy.jar"),
    },
    implementation = web_internal_favicon_image_generator,
    output_to_genfiles = True,
)

minify_ttf = rule(
    attrs = {
        "ttf": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "_ttx": web_internal_python_script_label("@font_tools//:ttx"),
        "_minify_ttx": web_internal_python_script_label("//:minify_ttx"),
    },
    implementation = web_internal_minify_ttf,
    output_to_genfiles = True,
    outputs = {
        "out_ttf": "%{name}__minified.ttf",
    },
)

ttf_to_woff = rule(
    attrs = {
        "ttf": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "_ttx": web_internal_python_script_label("@font_tools//:ttx"),
    },
    implementation = web_internal_ttf_to_woff,
    output_to_genfiles = True,
    outputs = {
        "out_woff": "%{name}__generated.woff",
    },
)

ttf_to_woff2 = rule(
    attrs = {
        "ttf": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "_ttf2woff2": web_internal_tool_label("@woff2//:ttf2woff2"),
        "_file_copy": web_internal_python_script_label("//:file_copy"),
    },
    implementation = web_internal_ttf_to_woff2,
    output_to_genfiles = True,
    outputs = {
        "out_woff2": "%{name}__generated.woff2",
    },
)

ttf_to_eot = rule(
    attrs = {
        "ttf": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "_ttf2eot": web_internal_tool_label("@ttf2eot//:ttf2eot"),
    },
    implementation = web_internal_ttf_to_eot,
    output_to_genfiles = True,
    outputs = {
        "out_eot": "%{name}__generated.eot",
    },
)

font_generator = rule(
    attrs = {
        "font_name": attr.string(
            mandatory = True,
        ),
        "eot": attr.label(
            allow_files = True,
            single_file = True,
        ),
        "ttf": attr.label(
            allow_files = True,
            single_file = True,
        ),
        "woff": attr.label(
            allow_files = True,
            single_file = True,
        ),
        "woff2": attr.label(
            allow_files = True,
            single_file = True,
        ),
        "svg": attr.label(
            allow_files = True,
            single_file = True,
        ),
        "weight": attr.string(
            default = "normal",
            values = [
                100,
                200,
                300,
                400,
                500,
                600,
                700,
                800,
                900,
                "ligher",
                "normal",
                "bold",
                "bolder",
            ],
        ),
        "style": attr.string(
            default = "normal",
            values = [
                "normal",
                "italic",
            ],
        ),
    },
    implementation = web_internal_font_generator,
    output_to_genfiles = True,
    outputs = {
        "out_css": "%{name}__generated.css"
    },
)

zip_site = rule(
    attrs = {
        "root_files": attr.label_list(),
        "resources": attr.label_list(),
        "out_zip": attr.output(
            mandatory = True,
        ),
        "_zip_site_script": web_internal_python_script_label("//:zip_site"),
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
        "_minify_site_zip_script": web_internal_python_script_label("//:minify_site_zip"),
    },
    implementation = web_internal_minify_site_zip,
)

rename_zip_paths = rule(
    attrs = {
        "source_zip": attr.label(
            mandatory = True,
            allow_files = True,
            single_file = True,
        ),
        "path_map_labels_in": attr.label_list(
            allow_files = True,
        ),
        "path_map_labels_out": attr.string_list(),
        "path_map": attr.string_dict(),
        "out_zip": attr.output(
            mandatory = True,
        ),
        "_rename_zip_paths_script": web_internal_python_script_label("//:rename_zip_paths"),
    },
    implementation = web_internal_rename_zip_paths,
)

generate_zip_server_python_file = rule(
    attrs = {
        "zip": attr.label(
            single_file = True,
        ),
        "port": attr.int(),
        "out_file": attr.output(),
        "_template": attr.label(
            default = Label("//templates:zip_server.py.jinja2"),
            allow_files = True,
            single_file = True,
        ),
        "_generate_jinja_file": web_internal_python_script_label("//:generate_templated_file"),
    },
    output_to_genfiles = True,
    implementation = web_internal_generate_zip_server_python_file,
)

def zip_server(name, zip, port=80):
    generated_file_target = "{name}__args".format(name=name)
    generated_file_name = "zip_server_{name}.py".format(name=name)

    generate_zip_server_python_file(
        name = generated_file_target,
        zip = zip,
        port = port,
        out_file = generated_file_name,
    )

    # This group is so the generated zip can be referenced as data by the binary as it can't be
    # consumed directly.
    fg_name = "{name}__zip_filegroup".format(name=name)
    native.filegroup(
        name = fg_name,
        srcs = [ zip ]
    )

    native.py_binary(
        name = name,
        srcs = [
            ":{generated_file_target}".format(generated_file_target=generated_file_target),
        ],
        data = [
            fg_name,
        ],
        srcs_version = "PY3",
        default_python_version = "PY3",
        main = generated_file_name,
    )

generate_deploy_site_zip_s3_script = rule(
    attrs = {
        "aws_access_key": attr.string(
            mandatory = True,
        ),
        "aws_secret_key": attr.string(
            mandatory = True,
        ),
        "bucket": attr.string(
            mandatory = True,
        ),
        "zip": attr.label(
            mandatory = True,
            allow_files = True,
            single_file = True,
        ),
        "_deploy_site_zip_to_s3_template": attr.label(
            default = Label("//templates:deploy_site_zip_to_s3.py.jinja2"),
            executable = True,
            cfg = "host",
            allow_files = True,
            single_file = True,
        ),
        "_s3_website_deploy": web_internal_python_script_label("//:s3_website_deploy"),
        "_s3_website_deploy_script_builder": web_internal_python_script_label("//:s3_website_deploy_script_builder"),
    },
    implementation = web_internal_generate_deploy_site_zip_s3_script,
    outputs = {
        "generated_script": "deploy_site_zip_s3_%{name}.py",
    },
)

# Currently broken due to:
# https://github.com/bazelbuild/bazel/issues/1192
#   Skylark ctx.command doesn't incorporate runfiles from input executables;
#   py_binary/java_binary executables fail
# https://github.com/bazelbuild/bazel/issues/1136
#   Can't invoke py_binary or java_binary from Skylark action
def deploy_site_zip_s3_script(name, aws_access_key, aws_secret_key, bucket, zip):
    script_name = name + "_script"
    generate_deploy_site_zip_s3_script(
        name = script_name,
        aws_access_key = aws_access_key,
        aws_secret_key = aws_secret_key,
        bucket = bucket,
        zip = zip,
    )

    native.py_binary(
        name = name,
        main = "deploy_site_zip_s3_" + script_name + ".py",
        srcs = [ ":" + script_name ],
        visibility = [ "//visibility:public" ],
    )
