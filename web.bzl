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
    "web_internal_rename_zip_paths",
    "web_internal_generate_zip_server_python_file",
    "web_internal_generate_deploy_site_zip_s3_script",
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
        "_rename_zip_paths_script": attr.label(
            default = Label("//:rename_zip_paths"),
            executable = True,
            allow_files = True,

            # single_file cannot be used while py_binary produces multiple
            # files, the binary of which is not selectable as a specific target
            # the way java_binary is
            # single_file = True,
        )
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
        "_generate_jinja_file": attr.label(
            default = Label("//:generate_templated_file"),
            executable = True,
            allow_files = True,

            # single_file cannot be used while py_binary produces multiple
            # files, the binary of which is not selectable as a specific target
            # the way java_binary is
            # single_file = True,
        ),
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
            allow_files = True,
            single_file = True,
        ),
        "_s3_website_deploy": attr.label(
            default = Label("//:s3_website_deploy"),
            executable = True,
            allow_files = True,

            # single_file cannot be used as the wrapper executable script is not selectable as a
            # specific target.
            # single_file = True,
        ),
        "_s3_website_deploy_script_builder": attr.label(
            default = Label("//:s3_website_deploy_script_builder"),
            executable = True,
            allow_files = True,

            # single_file cannot be used while py_binary produces multiple
            # files, the binary of which is not selectable as a specific target
            # the way java_binary is
            # single_file = True,
        ),
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
