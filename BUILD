# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

exports_files([
    "deploy_site_zip_to_s3.py.jinja2",
    "index.jinja2",
])

py_library(
    name = "jinja_helper",
    srcs = [
        "scripts/jinja_helper.py",
    ],
    deps = [
        "@jinja//:jinja",
    ],
    visibility = [ "//visibility:public" ],
)

py_binary(
    name = "file_copy",
    srcs = [
        "scripts/file_copy.py",
    ],
    visibility = [ "//visibility:public" ],
)

py_binary(
    name = "html_template",
    srcs = [
        "scripts/html_template.py",
    ],
    deps = [
        "@jinja//:jinja",
    ],
    visibility = [ "//visibility:public" ],
)

py_binary(
    name = "resize_image",
    srcs = [
        "scripts/resize_image.py",
    ],
    visibility = [ "//visibility:public" ],
)

py_binary(
    name = "zip_site",
    srcs = [
        "scripts/zip_site.py",
    ],
    visibility = [ "//visibility:public" ],
)

py_binary(
    name = "minify_site_zip",
    srcs = [
        "scripts/minify_site_zip.py",
    ],
    visibility = [ "//visibility:public" ],
)

java_binary(
    name = "html_compressor",
    main_class = "com.googlecode.htmlcompressor.CmdLineCompressor",
    runtime_deps = [ "@http_compressor//jar" ],
    visibility = [ "//visibility:public" ],
)

py_binary(
    name = "rename_zip_paths",
    srcs = [
        "scripts/rename_zip_paths.py",
    ],
    visibility = [ "//visibility:public" ],
)

py_binary(
    name = "generate_templated_file",
    srcs = [
        "scripts/generate_templated_file.py",
    ],
    deps = [
        ":jinja_helper"
    ],
    visibility = [ "//visibility:public" ],
)

py_binary(
    name = "minify_ttx",
    srcs = [
        "scripts/minify_ttx.py",
    ],
    visibility = [ "//visibility:public" ],
)

py_binary(
    name = "zip_server",
    srcs = [
        "scripts/zip_server.py",
    ],
    srcs_version = "PY3",
    default_python_version = "PY3",
    visibility = [ "//visibility:public" ],
)

py_binary(
    name = "s3_website_deploy_script_builder",
    srcs = [
        "scripts/s3_website_deploy_script_builder.py",
    ],
    deps = [
        "@jinja//:jinja",
    ],
    visibility = [ "//visibility:public" ],
)

java_binary(
    name = "s3_website_deploy",
    main_class = "com.dustindoloff.s3websitedeploy.Main",
    srcs = [
        "s3_website_deploy/java/src/com/dustindoloff/s3websitedeploy/Main.java",
    ],
    deps = [
        "@org_apache_commons_cli//jar",
        "@com_amazonaws_aws_java_sdk_core//jar",
        "@com_amazonaws_aws_java_sdk_kms//jar",
        "@com_amazonaws_aws_java_sdk_s3//jar",
    ],
    visibility = [ "//visibility:public" ],
)
