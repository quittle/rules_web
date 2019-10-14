# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

java_binary(
    name = "closure_compiler",
    main_class = "com.google.javascript.jscomp.CommandLineRunner",
    visibility = ["//visibility:public"],
    runtime_deps = ["@com_google_javascript_closure_compiler//jar"],
)

py_binary(
    name = "resource_map",
    srcs = [
        "scripts/resource_map.py",
    ],
    visibility = ["//visibility:public"],
)
