# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load(":internal.bzl",
    "web_internal_python_script_label",
    "web_internal_generate_deploy_site_zip_s3_script",
)

# Currently broken due to:
# https://github.com/bazelbuild/bazel/issues/1192
#   Skylark ctx.command doesn't incorporate runfiles from input executables;
#   py_binary/java_binary executables fail
# https://github.com/bazelbuild/bazel/issues/1136
#   Can't invoke py_binary or java_binary from Skylark action
def deploy_site_zip_s3_script(name, aws_access_key, aws_secret_key, bucket, zip_file):
    script_name = name + "_script"
    web_internal_generate_deploy_site_zip_s3_script(
        name = script_name,
        aws_access_key = aws_access_key,
        aws_secret_key = aws_secret_key,
        bucket = bucket,
        zip = zip_file,
    )

    native.py_binary(
        name = name,
        main = "deploy_site_zip_s3_" + script_name + ".py",
        srcs = [ ":" + script_name ],
        visibility = [ "//visibility:public" ],
    )