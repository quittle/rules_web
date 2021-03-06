# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load(
    "@bazel_toolbox//labels:labels.bzl",
    "executable_label",
)
load(
    ":internal.bzl",
    "web_internal_generate_zip_server_python_file",
    "web_internal_rename_zip_paths",
    "web_internal_zip_site",
)

zip_site = rule(
    attrs = {
        "root_files": attr.label_list(),
        "resources": attr.label_list(),
        "out_zip": attr.output(
            mandatory = True,
        ),
        "_zip_site_script": executable_label(Label("//site_zip:zip_site")),
    },
    implementation = web_internal_zip_site,
)

_rename_zip_paths = rule(
    attrs = {
        "source_zip": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "path_map_labels_in": attr.label_list(
            allow_files = True,
        ),
        "path_map_labels_out": attr.string_list(),
        "_rename_zip_paths_script": executable_label(Label("//site_zip:rename_zip_paths")),
    },
    outputs = {
        "out_zip": "%{name}.zip",
    },
    implementation = web_internal_rename_zip_paths,
)

def rename_zip_paths(name = None, source_zip = None, path_map = None):
    return _rename_zip_paths(
        name = name,
        source_zip = source_zip,
        path_map_labels_in = path_map.keys(),
        path_map_labels_out = path_map.values(),
    )

generate_zip_server_python_file = rule(
    attrs = {
        "zip": attr.label(
            allow_single_file = True,
        ),
        "host": attr.string(
            mandatory = True,
        ),
        "port": attr.int(
            mandatory = True,
        ),
        "out_file": attr.output(),
        "_template": attr.label(
            default = Label("//site_zip/templates:zip_server.py.jinja2"),
            allow_single_file = True,
        ),
        "_generate_jinja_file": executable_label("@bazel_toolbox//actions:generate_templated_file"),
    },
    output_to_genfiles = True,
    implementation = web_internal_generate_zip_server_python_file,
)

def zip_server(name, zip, host = "localhost", port = 80):
    generated_file_target = "{name}__args".format(name = name)
    generated_file_name = "zip_server_{name}.py".format(name = name)

    generate_zip_server_python_file(
        name = generated_file_target,
        zip = zip,
        host = host,
        port = port,
        out_file = generated_file_name,
    )

    # This group is so the generated zip can be referenced as data by the binary as it can't be
    # consumed directly.
    fg_name = "{name}__zip_filegroup".format(name = name)
    native.filegroup(
        name = fg_name,
        srcs = [zip],
    )

    native.py_binary(
        name = name,
        srcs = [
            ":{generated_file_target}".format(generated_file_target = generated_file_target),
        ],
        data = [
            fg_name,
        ],
        main = generated_file_name,
    )
