# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

py_binary(
    name = "s3_website_deploy_script_builder",
    srcs = [
        "scripts/s3_website_deploy_script_builder.py",
    ],
    deps = [
        "@jinja//:jinja",
    ],
    data = [
        ":s3_website_deploy",
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
        "@com_fasterxml_jackson_core_jackson_annotations//jar",
        "@com_fasterxml_jackson_core_jackson_core//jar",
        "@com_fasterxml_jackson_core_jackson_databind//jar",
        "@joda_time_joda_time//jar",
        "@org_apache_commons_cli//jar",
        "@org_apache_commons_io//jar",
        "@org_apache_commons_logging//jar",
        "@org_apache_httpcomponents_httpclient//jar",
        "@org_apache_httpcomponents_httpcore//jar",
    ],
    visibility = [ "//visibility:public" ],
)
