# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load(":internal.bzl",
    "web_internal_generate_zip_server_python_file",
    "web_internal_minify_site_zip",
    "web_internal_tool_label",
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
        "_zip_site_script": web_internal_tool_label("//site_zip:zip_site"),
    },
    implementation = web_internal_zip_site,
)

minify_site_zip = rule(
    attrs = {
        "site_zip": attr.label(
            mandatory = True,
            allow_files = True,
            single_file = True,
        ),
        "root_files": attr.label_list(),
        "minified_zip": attr.output(
            mandatory = True,
        ),
        "_minify_site_zip_script": web_internal_tool_label("//site_zip:minify_site_zip"),
    },
    implementation = web_internal_minify_site_zip,
)

rename_zip_paths = rule(
    attrs = {
        "source_zip": attr.label(
            mandatory = True,
            allow_files = True,
            single_file = True,
        ),
        "path_map_labels_in": attr.label_list(
            allow_files = True,
        ),
        "path_map_labels_out": attr.string_list(),
        "path_map": attr.string_dict(),
        "out_zip": attr.output(
            mandatory = True,
        ),
        "_rename_zip_paths_script": web_internal_tool_label("//site_zip:rename_zip_paths"),
    },
    implementation = web_internal_rename_zip_paths,
)

generate_zip_server_python_file = rule(
    attrs = {
        "zip": attr.label(
            single_file = True,
        ),
        "port": attr.int(),
        "out_file": attr.output(),
        "_template": attr.label(
            default = Label("//site_zip/templates:zip_server.py.jinja2"),
            allow_files = True,
            single_file = True,
        ),
        "_generate_jinja_file": web_internal_tool_label("//:generate_templated_file"),
    },
    output_to_genfiles = True,
    implementation = web_internal_generate_zip_server_python_file,
)

def zip_server(name, zip, port = 80):
    generated_file_target = "{name}__args".format(name=name)
    generated_file_name = "zip_server_{name}.py".format(name=name)

    generate_zip_server_python_file(
        name = generated_file_target,
        zip = zip,
        port = port,
        out_file = generated_file_name,
    )

    # This group is so the generated zip can be referenced as data by the binary as it can't be
    # consumed directly.
    fg_name = "{name}__zip_filegroup".format(name=name)
    native.filegroup(
        name = fg_name,
        srcs = [ zip ]
    )

    native.py_binary(
        name = name,
        srcs = [
            ":{generated_file_target}".format(generated_file_target=generated_file_target),
        ],
        data = [
            fg_name,
        ],
        srcs_version = "PY3",
        default_python_version = "PY3",
        main = generated_file_name,
    )
