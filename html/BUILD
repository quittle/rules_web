# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

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

java_binary(
    name = "html_compressor",
    main_class = "com.googlecode.htmlcompressor.CmdLineCompressor",
    runtime_deps = [ "@http_compressor//jar" ],
    visibility = [ "//visibility:public" ],
)
