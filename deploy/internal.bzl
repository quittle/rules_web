# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("@bazel_toolbox//labels:labels.bzl",
    "executable_label",
)

def _generate_deploy_site_zip_s3_script(ctx):
    ctx.action(
        mnemonic = "GeneratingS3DeployScript",
        arguments = [
            "--aws-access-key", ctx.attr.aws_access_key,
            "--aws-secret-key", ctx.attr.aws_secret_key,
            "--bucket", ctx.attr.bucket,
            "--deploy-executable", ctx.executable._s3_website_deploy.path,
            "--deployment-jinja-template", ctx.file._deploy_site_zip_to_s3_template.path,
            "--generated-file", ctx.outputs.generated_script.path,
            "--website-zip", ctx.file.zip.path,
        ],
        inputs = [
            ctx.file.zip,
            ctx.file._deploy_site_zip_to_s3_template,
            ctx.executable._s3_website_deploy,
            ctx.executable._s3_website_deploy_script_builder,
        ],
        outputs = [ ctx.outputs.generated_script ],
        executable = ctx.executable._s3_website_deploy_script_builder,
    )

web_internal_generate_deploy_site_zip_s3_script = rule(
    attrs = {
        "aws_access_key": attr.string(
            mandatory = True,
        ),
        "aws_secret_key": attr.string(
            mandatory = True,
        ),
        "bucket": attr.string(
            mandatory = True,
        ),
        "zip": attr.label(
            mandatory = True,
            allow_files = True,
            single_file = True,
        ),
        "_deploy_site_zip_to_s3_template": attr.label(
            default = Label("//deploy/templates:deploy_site_zip_to_s3.py.jinja2"),
            executable = True,
            cfg = "host",
            allow_files = True,
            single_file = True,
        ),
        "_s3_website_deploy": executable_label(Label("//deploy:s3_website_deploy")),
        "_s3_website_deploy_script_builder":
                executable_label(Label("//deploy:s3_website_deploy_script_builder")),
    },
    implementation = _generate_deploy_site_zip_s3_script,
    outputs = {
        "generated_script": "deploy_site_zip_s3_%{name}.py",
    },
)
