# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load(":internal.bzl",
    "web_internal_favicon_image_generator",
    "web_internal_minify_png",
    "web_internal_generate_ico",
)

load("//:internal.bzl",
    "web_internal_python_script_label",
    "web_internal_tool_label",
)

favicon_image_generator = rule(
    attrs = {
        "image": attr.label(
            single_file = True,
            allow_files = True,
            mandatory = True,
        ),
        "output_files": attr.output_list(
            allow_empty = False,
            mandatory = True,
        ),
        "output_sizes": attr.int_list(
            allow_empty = False,
        ),
        "allow_upsizing": attr.bool(
            default = False,
        ),
        "allow_stretching": attr.bool(
            default = False,
        ),
        "_resize_image": web_internal_python_script_label("//images:resize_image"),
        "_pngtastic": web_internal_tool_label("//images:simplified_pngtastic_deploy.jar"),
    },
    implementation = web_internal_favicon_image_generator,
    output_to_genfiles = True,
)

minify_png = rule(
    attrs = {
        "png": attr.label(
            single_file = True,
            allow_files = True,
            mandatory = True,
        ),
        "_pngtastic": web_internal_tool_label("//images:simplified_pngtastic_deploy.jar"),
    },
    outputs = {
        "min_png": "minified_png/%{name}.png",
    },
    implementation = web_internal_minify_png,
)

# BUG: This doesn't work as PIL does not support writing out ICO files
_generate_ico = rule(
    attrs = {
        "source": attr.label(
            single_file = True,
            allow_files = True,
            mandatory = True,
        ),
        "sizes": attr.int_list(
            mandatory = True,
            allow_empty = False,
        ),
        "allow_upsizing": attr.bool(
            default = False,
        ),
        "_generate_ico": web_internal_python_script_label("//images:generate_ico"),
    },
    outputs = {
        # Due to limitations of pngtastic, we will create an intermediate file without the
        # ".min.png" suffix as well and want it to have a readable name.
        "ico": "%{name}.ico",
    },
    implementation = web_internal_generate_ico,
    output_to_genfiles = True,
)
