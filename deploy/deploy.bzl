# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load(":internal.bzl",
    "web_internal_generate_deploy_site_zip_s3_script",
    "web_internal_generate_wrapper_script",
)

CACHE_DURATION_IMMUTABLE = -1

def deploy_site_zip_s3_script(name, bucket, zip_file, cache_durations=[], path_redirects={}):
    """
        cache_durations should be a list that mirrors a dictionary. Cannot be represented by a
        `dict` because they do not maintain order
        [
            123: [ "index.hml" ],
            999: [ "*" ],
        ]
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
        cache_durations = str(cache_durations),
        path_redirects = path_redirects,
    )

    native.py_binary(
        name = name,
        main = "deploy_site_zip_s3_" + script_name + ".py",
        srcs = [ ":" + script_name ],
        data =  [
            "@rules_web//deploy:s3_website_deploy",
        ],
        visibility = [ "//visibility:public" ],
    )

def generate_wrapper_script(name, binary, arguments, not_labels=[]):
    script_name = "{name}_script".format(name=name)

    wrapper_script = "generate_wrapper_script_{name}.py".format(name=script_name)

    label_replacements = { arg: arg
            for arg in arguments
                    if arg.startswith(":") and
                            len(arg) > 1 and
                            arg not in not_labels }

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
        srcs = [ ":{name}".format(name=script_name) ],
        visibility = [ "//visibility:public" ],
    )
