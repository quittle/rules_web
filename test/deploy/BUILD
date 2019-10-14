# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load(
    "//deploy:deploy.bzl",
    "deploy_lambda_function_script",
    "deploy_site_zip_s3_script",
)

java_library(
    name = "test_java_library",
    srcs = glob(["*.java"]),
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_member_explicit_constructor_script",
    function_handler = "MemberHandlerExplicitConstructor::handle",
    function_name = "test_function_name",
    function_role = "arn:aws:iam::123456789012:role/role",
    language = "java",
    library = ":test_java_library",
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_member_implicit_constructor_script",
    function_handler = "MemberHandlerImplicitConstructor::handle",
    function_name = "test_function_name",
    function_role = "arn:aws:iam::123456789012:role/role",
    language = "java",
    library = ":test_java_library",
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_static_script",
    function_handler = "StaticHandler::handle",
    function_name = "test_function_name",
    function_role = "arn:aws:iam::123456789012:role/role",
    language = "java",
    library = ":test_java_library",
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_unspecified_script",
    function_handler = "StaticHandler",
    function_name = "test_function_name",
    function_role = "arn:aws:iam::123456789012:role/role",
    language = "java",
    library = ":test_java_library",
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_region_script",
    function_handler = "StaticHandler",
    function_name = "test_function_name",
    function_role = "arn:aws:iam::123456789012:role/role",
    language = "java",
    library = ":test_java_library",
    region = "eu-west-1",
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_memory",
    function_handler = "StaticHandler",
    function_name = "test_function_name",
    function_role = "arn:aws:iam::123456789012:role/role",
    language = "java",
    library = ":test_java_library",
    memory = 192,
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_timeout",
    timeout = 10,
    function_handler = "StaticHandler",
    function_name = "test_function_name",
    function_role = "arn:aws:iam::123456789012:role/role",
    language = "java",
    library = ":test_java_library",
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_environment",
    environment = {
        "key": "value",
        "a": "b",
    },
    function_handler = "StaticHandler",
    function_name = "test_function_name",
    function_role = "arn:aws:iam::123456789012:role/role",
    language = "java",
    library = ":test_java_library",
)

deploy_site_zip_s3_script(
    name = "test_deploy_site_zip_s3_script",
    bucket = "bucket",
    cache_durations = {
        12: ["index.html"],
        1: ["*"],
    },
    content_types = {
        "swzl": "application/swizl",
    },
    path_redirects = {
        "a": "http://a.com",
        "b": "https://a.com",
        "c": "/d",
    },
    zip_file = ":test_java_library",
)
