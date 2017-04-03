# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

java_binary(
    name = "html_compressor",
    main_class = "com.googlecode.htmlcompressor.CmdLineCompressor",
    runtime_deps = [ "@html_compressor//jar" ],
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

java_binary(
    name = "inject_html",
    srcs = glob([ "scripts/inject_html/src/java/**/*.java" ]),
    main_class = "com.dustindoloff.injecthtml.Main",
    deps = [
        "@br_com_starcode_parccser_parccser//jar",
        "@net_htmlparser_jericho_jericho_html//jar",
        "@org_apache_commons_cli//jar",
        "@org_apache_commons_io//jar",
        "@utluiz_jericho_selector//:jericho_selector",
    ],
    visibility = [ "//visibility:public" ],
)
