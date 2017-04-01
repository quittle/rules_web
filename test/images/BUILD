# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load("@bazel_toolbox//assert:assert.bzl",
    "assert_files_equal",
    "assert_label_providers",
)

load("//images:images.bzl",
    "favicon_image_generator",
    "minify_png",
    "resize_image",
)

load("//test:test.bzl",
    "assert_descending_sizes",
    "assert_valid_type",
)

minify_png(
    name = "test_minify_png",
    png = "test.png",
)
assert_valid_type(":test_minify_png", "png")
assert_descending_sizes([ "test.png", ":test_minify_png" ])
assert_label_providers(
    ":test_minify_png",
    {
        "aspect_ids": [],
        "resources": [
            "{BIN_DIR}/test/images/minified_png/test_minify_png.png",
        ],
        "source_map": {
            "test/images/test.png": "{BIN_DIR}/test/images/minified_png/test_minify_png.png",
        },
    },
)

regular_sizes = [ 100, 32, 16, 1 ]
regular_output_files = [ "{size}.png".format(size=size) for size in regular_sizes ]
favicon_image_generator(
    name = "test_favicon_image_generator",
    image = "test.png",
    output_files = regular_output_files,
    output_sizes = regular_sizes,
)
assert_valid_type(":test_favicon_image_generator", "png")
assert_descending_sizes(":test_favicon_image_generator")
assert_label_providers(
    ":test_favicon_image_generator",
    {
        "aspect_ids": [],
        "resources": [
            "{GEN_DIR}/test/images/1.png",
            "{GEN_DIR}/test/images/16.png",
            "{GEN_DIR}/test/images/32.png",
            "{GEN_DIR}/test/images/100.png",
        ],
    },
)

upsize_sizes = [ 1000 ]
upsize_output_files = [ "{size}.png".format(size=size) for size in upsize_sizes ]
favicon_image_generator(
    name = "test_favicon_image_generator_upsize",
    image = "test.png",
    output_files = upsize_output_files,
    output_sizes = upsize_sizes,
    allow_upsizing = True,
)
assert_valid_type(":test_favicon_image_generator_upsize", "png")
assert_descending_sizes([ ":test_favicon_image_generator_upsize", "test.png" ])
assert_label_providers(
    ":test_favicon_image_generator_upsize",
    {
        "aspect_ids": [],
        "resources": [
            "{GEN_DIR}/test/images/1000.png",
        ],
    },
)

resize_image(
    name = "test_resize_image_exact",
    image = "white-10x10.bmp",
    width = 5,
    height = 20,
)
assert_valid_type(":test_resize_image_exact", "bmp")
assert_files_equal("white-5x20.bmp", ":test_resize_image_exact")
assert_label_providers(
    ":test_resize_image_exact",
    {
        "aspect_ids": [],
        "resources": [
            "{BIN_DIR}/test/images/resize_image/test_resize_image_exact",
        ],
    },
)

resize_image(
    name = "test_resize_image_given_width",
    image = "white-10x10.bmp",
    width = 5,
)
assert_valid_type(":test_resize_image_given_width", "bmp")
assert_files_equal("white-5x5.bmp", ":test_resize_image_given_width")
assert_label_providers(
    ":test_resize_image_given_width",
    {
        "aspect_ids": [],
        "resources": [
            "{BIN_DIR}/test/images/resize_image/test_resize_image_given_width",
        ],
    },
)

resize_image(
    name = "test_resize_image_given_height",
    image = "white-5x5.bmp",
    height = 10,
)
assert_valid_type(":test_resize_image_given_height", "bmp")
assert_files_equal("white-10x10.bmp", ":test_resize_image_given_height")
assert_label_providers(
    ":test_resize_image_given_height",
    {
        "aspect_ids": [],
        "resources": [
            "{BIN_DIR}/test/images/resize_image/test_resize_image_given_height",
        ],
    },
)

resize_image(
    name = "test_resize_image_scale",
    image = "white-10x10.bmp",
    scale = ".5"
)
assert_valid_type(":test_resize_image_scale", "bmp")
assert_files_equal("white-5x5.bmp", ":test_resize_image_scale")
assert_label_providers(
    ":test_resize_image_scale",
    {
        "aspect_ids": [],
        "resources": [
            "{BIN_DIR}/test/images/resize_image/test_resize_image_scale",
        ],
    },
)
