# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load("@bazel_toolbox//labels:labels.bzl",
    "executable_label",
)

load("//:internal.bzl",
    "optional_arg_",
)

def _generate_deploy_site_zip_s3_script(ctx):
    ctx.action(
        mnemonic = "GeneratingS3DeployScript",
        arguments = [
            "--bucket", ctx.attr.bucket,
            "--cache-durations", ctx.attr.cache_durations,
            "--path-redirects", repr(ctx.attr.path_redirects),
            "--deployment-jinja-template", ctx.file._deploy_site_zip_to_s3_template.path,
            "--generated-file", ctx.outputs.generated_script.path,
            "--website-zip", ctx.file.zip.path,
        ],
        inputs = [
            ctx.file.zip,
            ctx.file._deploy_site_zip_to_s3_template,
            ctx.executable._s3_website_deploy_script_builder,
        ],
        outputs = [ ctx.outputs.generated_script ],
        executable = ctx.executable._s3_website_deploy_script_builder,
    )

web_internal_generate_deploy_site_zip_s3_script = rule(
    attrs = {
        "bucket": attr.string(
            mandatory = True,
        ),
        "zip": attr.label(
            mandatory = True,
            allow_files = True,
            single_file = True,
        ),
        # Because this should never be called directly, we use string serialization to pass in the
        # cache values
        "cache_durations": attr.string(
            default = repr([
                # 15 minutes
                "60 * 15", [ "*" ],
            ]),
        ),
        "path_redirects": attr.string_dict(
            default = {},
        ),
        "_deploy_site_zip_to_s3_template": attr.label(
            default = Label("//deploy/templates:deploy_site_zip_to_s3.py.jinja2"),
            executable = True,
            cfg = "host",
            allow_files = True,
            single_file = True,
        ),
        "_s3_website_deploy_script_builder":
                executable_label(Label("//deploy:s3_website_deploy_script_builder")),
    },
    implementation = _generate_deploy_site_zip_s3_script,
    outputs = {
        "generated_script": "deploy_site_zip_s3_%{name}.py",
    },
)

def _generate_wrapper_script(ctx):
    label_to_target = { value: key for key, value in ctx.attr.label_replacements.items() }

    arguments = []
    for arg in ctx.attr.arguments:
        arguments.push(label_to_target.get(arg, arg))

    ctx.action(
        mnemonic = "GeneratingWrapperScript",
        arguments = [
            "--executable", ctx.file.binary.path,
            "--generated-file", ctx.outputs.generated_script.path,
        ] + [ "--arguments" ] + arguments,
        inputs = [ ctx.file.binary ],
        executable = ctx.executable._execute_script_wrapper_builder,
        outputs = [ ctx.outputs.generated_script ],
    )

web_internal_generate_wrapper_script = rule(
    attrs = {
        "binary": attr.label(
            executable = True,
            mandatory = True,
            cfg = "host",
        ),
        "arguments": attr.string_list(
            mandatory = True,
        ),
        "label_replacements": attr.label_keyed_string_dict(
            allow_files = True,
        ),
        "generated_script": attr.output(),
        "_execute_script_wrapper_builder":
                executable_label(Label("//deploy:execute_script_wrapper_builder")),
    },
    implementation = _generate_wrapper_script,
)
