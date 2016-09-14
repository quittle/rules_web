# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

exports_files([
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
