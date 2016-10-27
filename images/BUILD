# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

py_binary(
    name = "generate_ico",
    srcs = [
        "scripts/create_ico.py",
    ],
    main = "scripts/create_ico.py",
    visibility = [ "//visibility:public" ],
)

py_binary(
    name = "resize_image",
    srcs = [
        "scripts/resize_image.py",
    ],
    visibility = [ "//visibility:public" ],
)

java_binary(
    name = "pngtastic",
    main_class = "com.googlecode.pngtastic.PngtasticOptimizer",
    runtime_deps = [ "@pngtastic//jar" ],
    visibility = [ "//visibility:public" ],
)

java_binary(
    name = "simplified_pngtastic",
    main_class = "com.dustindoloff.pngtastic.Main",
    srcs = [
        "pngtastic/java/src/com/dustindoloff/pngtastic/Main.java",
    ],
    deps = [
        "@org_apache_commons_cli//jar",
        "@pngtastic//jar",
    ],
    visibility = [ "//visibility:public" ],
)
