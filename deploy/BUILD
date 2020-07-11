# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

py_binary(
    name = "s3_website_deploy_script_builder",
    srcs = [
        "scripts/s3_website_deploy_script_builder.py",
    ],
    data = [
        ":s3_website_deploy",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@jinja",
    ],
)

py_binary(
    name = "execute_script_wrapper_builder",
    srcs = [
        "scripts/execute_script_wrapper_builder.py",
    ],
    data = [
        "//deploy/templates:execute_script_wrapper.py.jinja2",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@jinja",
    ],
)

java_import(
    name = "aws_sdk_core",
    jars = [],
    exports = [
        "@maven//:com_amazonaws_aws_java_sdk_core",
        "@maven//:com_fasterxml_jackson_core_jackson_annotations",
        "@maven//:com_google_code_findbugs_jsr305",
    ],
)

java_binary(
    name = "s3_website_deploy",
    srcs = glob(["s3_website_deploy/java/src/**/*.java"]),
    main_class = "com.dustindoloff.bazel.deploy.s3website.Main",
    visibility = ["//visibility:public"],
    deps = [
        ":aws_sdk_core",
        "@maven//:com_amazonaws_aws_java_sdk_kms",
        "@maven//:com_amazonaws_aws_java_sdk_s3",
        "@maven//:com_google_code_gson_gson",
        "@maven//:commons_cli_commons_cli",
        "@maven//:commons_io_commons_io",
        "@maven//:org_apache_commons_commons_lang3",
    ],
)

java_test(
    name = "s3_website_deploy_test",
    srcs = glob(["s3_website_deploy/java/test/**/*.java"]),
    test_class = "com.dustindoloff.bazel.deploy.s3website.MainTest",
    deps = [
        ":s3_website_deploy_deploy.jar",
    ],
)

java_binary(
    name = "lambda_function_deploy",
    srcs = glob(["lambda_function_deploy/java/src/**/*.java"]),
    main_class = "com.dustindoloff.bazel.deploy.lambda.Main",
    visibility = ["//visibility:public"],
    deps = [
        ":aws_sdk_core",
        "@maven//:com_amazonaws_aws_java_sdk_lambda",
        "@maven//:com_google_code_gson_gson",
        "@maven//:commons_cli_commons_cli",
    ],
)

java_library(
    name = "lambda_function_deploy_validation",
    srcs = glob(["lambda_function_deploy_validation/java/src/**/*.java"]),
    visibility = ["//visibility:public"],
    deps = [
        ":aws_sdk_core",
        "@maven//:com_amazonaws_aws_java_sdk_core",
        "@maven//:com_amazonaws_aws_java_sdk_lambda",
        "@maven//:junit_junit",
    ],
)
