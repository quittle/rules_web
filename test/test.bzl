# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load("@bazel_toolbox//collections:collections.bzl",
    "simple_dict",
    "struct_to_dict",
)

load("@bazel_toolbox//labels:labels.bzl",
    "executable_label",
)

load("@io_bazel_rules_sass//sass:sass.bzl",
    "sass_binary",
)

def _assert_descending_sizes_impl(ctx):
    ctx.action(
        mnemonic = "AssertingFilesOfDescendingSizes",
        arguments = [
                "--stamp", ctx.outputs.stamp_file.path,
            ] +
            [ "--files" ] + [ file.path for file in ctx.files.files ],
        inputs = [
                ctx.executable._assert_descending_sizes,
            ] +
            ctx.files.files,
        executable = ctx.executable._assert_descending_sizes,
        outputs = [
            ctx.outputs.stamp_file,
        ],
    )

def _assert_valid_type_impl(ctx):
    if ctx.attr.type in ["html", "json", "png"]:
        ctx.action(
            mnemonic = "AssertingValidFile",
            arguments = [
                    "--type", ctx.attr.type,
                    "--stamp", ctx.outputs.stamp_file.path,
                ] +
                [ "--files" ] + [ file.path for file in ctx.files.files ],
            inputs = [
                    ctx.executable._assert_valid_type,
                ] +
                ctx.files.files,
            executable = ctx.executable._assert_valid_type,
            outputs = [
                ctx.outputs.stamp_file,
            ],
        )
    elif ctx.attr.type in ["js", "css"]:
        ctx.action(
            mnemonic = "AssertingValidFile",
            arguments = [ file.path for file in ctx.files.files ] +
                [
                    "--type", ctx.attr.type,
                    "-o", ctx.outputs.stamp_file.path,
                ],
            inputs = [
                    ctx.executable._yui_binary,
                ] +
                ctx.files.files,
            executable = ctx.executable._yui_binary,
            outputs = [
                ctx.outputs.stamp_file,
            ],
        )
    else:
        fail("Unsupported type: " + ctx.attr.type)


_assert_descending_sizes = rule(
    attrs = {
        "files": attr.label_list(
            allow_empty = False,
            allow_files = True,
            mandatory = True,
        ),
        "_assert_descending_sizes":
                executable_label("//test:assert_descending_sizes"),
    },
    outputs = {
        "stamp_file": "assert/descending_sizes/%{name}.stamp",
    },
    implementation = _assert_descending_sizes_impl,
)

_assert_valid_type = rule(
    attrs = {
        "files": attr.label(
            mandatory = True,
        ),
        "type": attr.string(
            mandatory = True,
            values = [
                "css",
                "html",
                "js",
                "json",
                "png",
                "scss",
            ]
        ),
        "_assert_valid_type": executable_label("//test:assert_valid_type"),
        "_yui_binary": executable_label("@yui_compressor//:yui_compressor"),
    },
    outputs = {
        "stamp_file": "assert/valid_type/%{name}.stamp",
    },
    implementation = _assert_valid_type_impl,
)

def _normalize_name(name):
    # These names can make the paths extra long so use abbreviations
    return (name
            .replace(" ", "-")
            .replace(":", "_cln_")
            .replace("\"", "_qte_")
            .replace("{", "_ocbr_")
            .replace("}", "_ccbr_")
            .replace("[", "_osbr_")
            .replace("]", "_csbr_"))

def assert_descending_sizes(files):
    if type(files) != "list":
        files = [ files ]

    name = "assert_descending_sizes_{files}".format(files = "-".join(files))
    name = _normalize_name(name)

    _assert_descending_sizes(
        name = name,
        files = files,
    )

def assert_valid_type(files, file_type):
    name = "assert_valid_type_{files}_{type}".format(files = files, type = file_type)
    name = _normalize_name(name)

    if file_type == "scss":
        if type(files) != "list":
            files = [ files ]

        for file in files:
            sass_binary(
                name = _normalize_name("{prefix}_{file}".format(prefix = name, file = file)),
                src = file,
            )
        return
    else:
        _assert_valid_type(
            name = name,
            files = files,
            type = file_type,
        )
