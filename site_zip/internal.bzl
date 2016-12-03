# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.

load("//:internal.bzl",
    "optional_arg_",
    "web_internal_python_script_label",
    "web_internal_generate_jinja_file",
)

def web_internal_zip_site(ctx):
    resources = set()
    source_map = {}
    for resource in ctx.attr.root_files + ctx.attr.resources:
        source_map += getattr(resource, "source_map", {})
        resources += getattr(resource, "resources", set())
        resources += getattr(resource, "css_resources", set())
        resources += getattr(resource, "js_resources", set())
    resources += ctx.files.resources

    root_files = [ page.path for page in ctx.files.root_files ]
    resource_paths = [ resource.path for resource in resources ]

    ctx.action(
        mnemonic = "ZipSite",
        arguments = [
                "--output", ctx.outputs.out_zip.path,
            ] +
            optional_arg_("--root-files", root_files) +
            optional_arg_("--resources", resource_paths),
        inputs = [
                ctx.executable._zip_site_script,
            ] +
            list(resources) +
            ctx.files.root_files,
        executable = ctx.executable._zip_site_script,
        outputs = [ ctx.outputs.out_zip ]
    )


    return struct(
        source_map = source_map,
    )

def web_internal_minify_site_zip(ctx):
    root_files = [ file.path for file in ctx.files.root_files ]

    ctx.action(
        mnemonic = "MinifySiteZip",
        arguments = [
                "--in-zip", ctx.file.site_zip.path,
                "--out-zip", ctx.outputs.minified_zip.path,
            ] +
            optional_arg_("--root-files", root_files),
        inputs = [
                ctx.executable._minify_site_zip_script,
                ctx.file.site_zip,
            ] +
            ctx.files.root_files,
        executable = ctx.executable._minify_site_zip_script,
        outputs = [ ctx.outputs.minified_zip ],
    )

def web_internal_rename_zip_paths(ctx):
    if len(ctx.files.path_map_labels_in) != len(ctx.attr.path_map_labels_out):
        fail("path_map_labels_in must be the same size as path_map_labels_out")


    path_map = { key: value for key, value in ctx.attr.path_map.items() }
    path_map.update({
            in_label.path: out_path
                    for in_label, out_path in
                            zip(ctx.files.path_map_labels_in, ctx.attr.path_map_labels_out) })

    path_map_list = [
        value
            for key in path_map
                for value in (key, path_map[key]) ]

    ctx.action(
        mnemonic = "RenameZipPaths",
        arguments = [
                "--in-zip", ctx.file.source_zip.path,
                "--out-zip", ctx.outputs.out_zip.path,
            ] +
            [ "--path-map" ] + path_map_list,
        inputs = [
            ctx.executable._rename_zip_paths_script,
            ctx.file.source_zip,
        ],
        executable = ctx.executable._rename_zip_paths_script,
        outputs = [ ctx.outputs.out_zip ],
    )

def web_internal_generate_zip_server_python_file(ctx):
    config = {
        "port": ctx.attr.port,
        "zip": ctx.file.zip.basename,
    }

    web_internal_generate_jinja_file(ctx, ctx.file._template, config, ctx.outputs.out_file)
