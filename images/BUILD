# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

py_binary(
    name = "generate_ico",
    srcs = [
        "scripts/create_ico.py",
    ],
    main = "scripts/create_ico.py",
    visibility = ["//visibility:public"],
)

py_binary(
    name = "crop_image",
    srcs = [
        "scripts/crop_image.py",
    ],
    visibility = ["//visibility:public"],
    deps = ["@pip//pillow"],
)

py_binary(
    name = "resize_image",
    srcs = [
        "scripts/resize_image.py",
    ],
    visibility = ["//visibility:public"],
    deps = ["@pip//pillow"],
)

java_binary(
    name = "pngtastic",
    main_class = "com.googlecode.pngtastic.PngtasticOptimizer",
    visibility = ["//visibility:public"],
    runtime_deps = ["@pngtastic//jar"],
)

java_binary(
    name = "simplified_pngtastic",
    srcs = [
        "pngtastic/java/src/com/dustindoloff/pngtastic/Main.java",
    ],
    main_class = "com.dustindoloff.pngtastic.Main",
    visibility = ["//visibility:public"],
    deps = [
        "@com_google_code_findbugs_jsr305//jar",
        "@org_apache_commons_cli//jar",
        "@pngtastic//jar",
    ],
)
