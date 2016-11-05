# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//images:images.bzl",
    "favicon_image_generator",
    "minify_png",
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
