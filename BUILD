# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

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
    name = "generate_templated_file",
    srcs = [
        "scripts/generate_templated_file.py",
    ],
    deps = [
        ":jinja_helper"
    ],
    visibility = [ "//visibility:public" ],
)
