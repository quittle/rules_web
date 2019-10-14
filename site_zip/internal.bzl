# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.

load(
    "@bazel_toolbox//actions:actions.bzl",
    "generate_templated_file",
)
load(
    "//:internal.bzl",
    "optional_arg_",
)

def web_internal_zip_site(ctx):
    resources = list()
    source_map = {}
    for resource in ctx.attr.root_files + ctx.attr.resources:
        source_map.update(getattr(resource, "source_map", {}))
        resources += getattr(resource, "resources", depset()).to_list()
        resources += getattr(resource, "css_resources", depset()).to_list()
        resources += getattr(resource, "js_resources", depset()).to_list()
        resources += getattr(resource, "deferred_js_resources", depset()).to_list()
    resources += ctx.files.resources

    root_files = [page.path for page in ctx.files.root_files]
    resource_paths = [resource.path for resource in resources]

    simple_source_map = {key: value.path for key, value in source_map.items()}

    ctx.actions.run(
        mnemonic = "ZipSite",
        arguments = [
                        "--output",
                        ctx.outputs.out_zip.path,
                        "--source-map",
                        str(simple_source_map),
                    ] +
                    optional_arg_("--root-files", root_files) +
                    optional_arg_("--resources", resource_paths),
        inputs = depset(resources).to_list() +
                 ctx.files.root_files,
        tools = [ctx.executable._zip_site_script],
        executable = ctx.executable._zip_site_script,
        outputs = [ctx.outputs.out_zip],
    )

    return struct(
        source_map = source_map,
    )

def web_internal_rename_zip_paths(ctx):
    if len(ctx.files.path_map_labels_in) != len(ctx.attr.path_map_labels_out):
        fail("path_map_labels_in must be the same size as path_map_labels_out")

    path_map = {}
    path_map.update({
        in_label.path: out_path
        for in_label, out_path in zip(ctx.files.path_map_labels_in, ctx.attr.path_map_labels_out)
    })

    path_map_list = [
        value
        for key in path_map
        for value in (key, path_map[key])
    ]

    ctx.actions.run(
        mnemonic = "RenameZipPaths",
        arguments = [
                        "--in-zip",
                        ctx.file.source_zip.path,
                        "--out-zip",
                        ctx.outputs.out_zip.path,
                    ] +
                    ["--path-map"] + path_map_list,
        inputs = [
            ctx.file.source_zip,
        ],
        tools = [
            ctx.executable._rename_zip_paths_script,
        ],
        executable = ctx.executable._rename_zip_paths_script,
        outputs = [ctx.outputs.out_zip],
    )

def web_internal_generate_zip_server_python_file(ctx):
    config = {
        "host": ctx.attr.host,
        "port": ctx.attr.port,
        "zip": ctx.file.zip.short_path,
    }

    generate_templated_file(ctx, ctx.executable._generate_jinja_file, ctx.file._template, config, ctx.outputs.out_file)
