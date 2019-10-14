# Copyright (c) 2016-2018 Dustin Toff
# Licensed under Apache License v2.0

java_binary(
    name = "html_compressor",
    main_class = "com.googlecode.htmlcompressor.CmdLineCompressor",
    visibility = ["//visibility:public"],
    runtime_deps = [
        "@html_compressor//jar",
    ],
)

py_binary(
    name = "html_template",
    srcs = [
        "scripts/html_template.py",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@jinja",
    ],
)

java_binary(
    name = "wrapped_nu_validator",
    srcs = [
        "java/ValidatorWrapper.java",
    ],
    main_class = "ValidatorWrapper",
    visibility = ["//visibility:public"],
    deps = [
        "@nu_validator//:validator",
    ],
)

java_binary(
    name = "inject_html",
    srcs = glob(["scripts/inject_html/src/java/**/*.java"]),
    main_class = "com.dustindoloff.injecthtml.Main",
    visibility = ["//visibility:public"],
    deps = [
        "@br_com_starcode_parccser_parccser//jar",
        "@com_google_code_findbugs_jsr305//jar",
        "@net_htmlparser_jericho_jericho_html//jar",
        "@org_apache_commons_cli//jar",
        "@org_apache_commons_io//jar",
        "@utluiz_jericho_selector//:jericho_selector",
    ],
)
