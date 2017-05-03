# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load(":internal.bzl",
    "web_internal_generate_deploy_site_zip_s3_script",
)

CACHE_DURATION_IMMUTABLE = -1

def deploy_site_zip_s3_script(name, bucket, zip_file, cache_durations = []):
    """
        cache_durations should be a list that mirrors a dictionary. Cannot be represented by a
        `dict` because they do not maintain order
        [
            123: [ "index.hml" ],
            999: [ "*" ],
        ]
    """

    script_name = name + "_script"
    web_internal_generate_deploy_site_zip_s3_script(
        name = script_name,
        bucket = bucket,
        zip = zip_file,
        cache_durations = str(cache_durations),
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
