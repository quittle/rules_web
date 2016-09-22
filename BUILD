# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

exports_files([
    "deploy_site_zip_to_s3.py.jinja2",
    "index.jinja2",
])

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
        "@apache_commons_cli//jar",
        "@aws_sdk_java//jar",
    ],
    visibility = [ "//visibility:public" ],
)
