# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

load("//deploy:deploy.bzl",
    "deploy_lambda_function_script"
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
