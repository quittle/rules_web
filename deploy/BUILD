# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

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
        "@com_amazonaws_aws_java_sdk_core//jar",
        "@com_amazonaws_aws_java_sdk_kms//jar",
        "@com_amazonaws_aws_java_sdk_s3//jar",
        "@org_apache_commons_cli//jar",
    ],
    visibility = [ "//visibility:public" ],
)