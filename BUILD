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