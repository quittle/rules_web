# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load("@bazel_toolbox//labels:labels.bzl",
    "executable_label",
)

load(":internal.bzl",
    "web_internal_crop_image",
    "web_internal_favicon_image_generator",
    "web_internal_generate_ico",
    "web_internal_minify_png",
    "web_internal_resize_image",
)

crop_image = rule(
    attrs = {
        "image": attr.label(
            single_file = True,
            allow_files = True,
            mandatory = True,
        ),
        "width": attr.string(default = "100%"),
        "height": attr.string(default = "100%"),
        "x_offset": attr.string(default = "0"),
        "y_offset": attr.string(default = "0"),
        "_crop_image": executable_label(Label("//images:crop_image")),
    },
    outputs = {
        "cropped_image": "crop_image/%{name}",
    },
    implementation = web_internal_crop_image,
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
        "_resize_image": executable_label(Label("//images:resize_image")),
        "_pngtastic": executable_label(Label("//images:simplified_pngtastic")),
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
        "_pngtastic": executable_label(Label("//images:simplified_pngtastic")),
    },
    outputs = {
        "min_png": "minified_png/%{name}.png",
    },
    implementation = web_internal_minify_png,
)

resize_image = rule(
    attrs = {
        "image": attr.label(
            single_file = True,
            allow_files = True,
            mandatory = True,
        ),
        "width": attr.int(default = -1),
        "height": attr.int(default = -1),
        "scale": attr.string(),
        "_resize_image": executable_label(Label("//images:resize_image")),
    },
    outputs = {
        "resized_image": "resize_image/%{name}",
    },
    implementation = web_internal_resize_image,
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
        "_generate_ico": executable_label(Label("//images:generate_ico")),
    },
    outputs = {
        # Due to limitations of pngtastic, we will create an intermediate file without the
        # ".min.png" suffix as well and want it to have a readable name.
        "ico": "%{name}.ico",
    },
    implementation = web_internal_generate_ico,
    output_to_genfiles = True,
)
