# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("//deploy:deploy.bzl",
    "deploy_lambda_function_script",
    "deploy_site_zip_s3_script",
)

java_library(
    name = "test_java_library",
    srcs = glob([ "*.java" ]),
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_member_explicit_constructor_script",
    function_name = "test_function_name",
    function_handler = "MemberHandlerExplicitConstructor::handle",
    function_role = "arn:aws:iam::123456789012:role/role",
    library = ":test_java_library",
    language = "java",
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_member_implicit_constructor_script",
    function_name = "test_function_name",
    function_handler = "MemberHandlerImplicitConstructor::handle",
    function_role = "arn:aws:iam::123456789012:role/role",
    library = ":test_java_library",
    language = "java",
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_static_script",
    function_name = "test_function_name",
    function_handler = "StaticHandler::handle",
    function_role = "arn:aws:iam::123456789012:role/role",
    library = ":test_java_library",
    language = "java",
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_unspecified_script",
    function_name = "test_function_name",
    function_handler = "StaticHandler",
    function_role = "arn:aws:iam::123456789012:role/role",
    library = ":test_java_library",
    language = "java",
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_region_script",
    function_name = "test_function_name",
    function_handler = "StaticHandler",
    function_role = "arn:aws:iam::123456789012:role/role",
    library = ":test_java_library",
    region = "eu-west-1",
    language = "java",
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_memory",
    function_name = "test_function_name",
    function_handler = "StaticHandler",
    function_role = "arn:aws:iam::123456789012:role/role",
    library = ":test_java_library",
    language = "java",
    memory = 192,
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_timeout",
    function_name = "test_function_name",
    function_handler = "StaticHandler",
    function_role = "arn:aws:iam::123456789012:role/role",
    library = ":test_java_library",
    language = "java",
    timeout = 10,
)

deploy_lambda_function_script(
    name = "test_deploy_lambda_function_environment",
    function_name = "test_function_name",
    function_handler = "StaticHandler",
    function_role = "arn:aws:iam::123456789012:role/role",
    library = ":test_java_library",
    language = "java",
    environment = {
        "key": "value",
        "a": "b",
    },
)

deploy_site_zip_s3_script(
    name = "test_deploy_site_zip_s3_script",
    bucket = "bucket",
    zip_file = ":test_java_library",
    cache_durations = {
        12: [ "index.html" ],
        1: [ "*" ],
    },
    content_types = {
        "swzl": "application/swizl",
    },
    path_redirects = {
        "a": "http://a.com",
        "b": "https://a.com",
        "c": "/d",
    },
)