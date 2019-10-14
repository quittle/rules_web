# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load(
    ":internal.bzl",
    "web_internal_generate_deploy_lambda_function_script",
    "web_internal_generate_deploy_site_zip_s3_script",
    "web_internal_generate_wrapper_script",
)

CACHE_DURATION_IMMUTABLE = -1

def deploy_site_zip_s3_script(name, bucket, zip_file, cache_durations = {60 * 15: ["*"]}, content_types = {}, path_redirects = {}):
    """
        cache_durations should be in the form
        {
            123: [ "index.hml" ],
            999: [ "*" ],
        }

        content_types should be in the form
        {
            "txt": "text/plain",
        }
    """

    for value in path_redirects.values():
        if not (value.startswith("/") or
                value.startswith("http://") or
                value.startswith("https://")):
            fail("Invalid redirect destination", value)

    script_name = name + "_script"
    web_internal_generate_deploy_site_zip_s3_script(
        name = script_name,
        bucket = bucket,
        zip = zip_file,
        cache_durations = str({str(key): value for key, value in cache_durations.items()}),
        content_types = content_types,
        path_redirects = path_redirects,
    )

    native.py_binary(
        name = name,
        main = "deploy_site_zip_s3_" + script_name + ".py",
        srcs = [":" + script_name],
        data = [
            "@rules_web//deploy:s3_website_deploy",
        ],
        visibility = ["//visibility:public"],
    )

def deploy_lambda_function_script(
        name,
        function_name,
        function_handler,
        function_role,
        library,
        language,
        region = None,
        memory = None,
        timeout = None,
        environment = {}):
    function_runtime = None
    bundle = None
    if language == "java":
        function_runtime = "java8"

        binary_name = name + "__binary"
        native.java_binary(
            name = binary_name,
            main_class = ".",  # Not real or actually used
            runtime_deps = [library],
        )
        bundle = binary_name + "_deploy.jar"

        native.java_test(
            name = name + "__lambda_function_deploy_validation",
            test_class = "com.dustindoloff.bazel.deploy.lambda.ValidationTest",
            jvm_flags = [
                            "-Dhandler={handler}".format(handler = function_handler),
                            "-Druntime={runtime}".format(runtime = function_runtime),
                        ] +
                        (["-Dregion={region}".format(region = region)] if region != None else []),
            runtime_deps = [
                bundle,
                "@rules_web//deploy:lambda_function_deploy_validation",
            ],
        )
    else:
        fail("Unsupported language", language)

    script_name = name + "_script"
    web_internal_generate_deploy_lambda_function_script(
        name = script_name,
        function_name = function_name,
        function_handler = function_handler,
        function_role = function_role,
        function_runtime = function_runtime,
        region = region,
        memory = memory,
        timeout = timeout,
        environment = environment,
        bundle = ":" + bundle,
    )

    native.py_binary(
        name = name,
        main = "deploy_lambda_function_" + script_name + ".py",
        srcs = [":" + script_name],
        data = [
            ":" + bundle,
            "@rules_web//deploy:lambda_function_deploy",
        ],
        visibility = ["//visibility:public"],
    )

def generate_wrapper_script(name, binary, arguments, not_labels = []):
    script_name = "{name}_script".format(name = name)

    wrapper_script = "generate_wrapper_script_{name}.py".format(name = script_name)

    label_replacements = {
        arg: arg
        for arg in arguments
        if arg.startswith(":") and
           len(arg) > 1 and
           arg not in not_labels
    }

    web_internal_generate_wrapper_script(
        name = script_name,
        binary = binary,
        arguments = arguments,
        label_replacements = label_replacements,
        generated_script = wrapper_script,
    )

    native.py_binary(
        name = name,
        main = wrapper_script,
        srcs = [":{name}".format(name = script_name)],
        visibility = ["//visibility:public"],
    )
