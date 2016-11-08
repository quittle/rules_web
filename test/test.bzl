# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//:internal.bzl",
    "simple_dict_",
    "struct_to_dict_",
    "web_internal_python_script_label",
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

def _assert_equal_impl(ctx):
    ctx.action(
        mnemonic = "AssertingFilesAreEqual",
        arguments = [
            "--files", ctx.file.expected_file.path, ctx.file.actual_file.path,
            "--stamp", ctx.outputs.stamp_file.path,
        ],
        inputs = [
            ctx.executable._assert_equal,
            ctx.file.expected_file,
            ctx.file.actual_file,
        ],
        executable = ctx.executable._assert_equal,
        outputs = [ ctx.outputs.stamp_file ]
    )

def _assert_valid_type_impl(ctx):
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

def _assert_label_struct_impl(ctx):
    actual_dict = str(simple_dict_(struct_to_dict_(ctx.attr.label)))
    expected_dict = ctx.attr.expected_struct_string.replace("{BIN_DIR}", ctx.bin_dir.path)
    if actual_dict != expected_dict:
        fail("label struct does not match expected struct. " +
             "Expected: {expected} Actual: {actual}".format(expected = expected_dict,
                                                            actual = actual_dict))

    ctx.file_action(
        content = "",
        output = ctx.outputs.stamp_file,
    )

_assert_descending_sizes = rule(
    attrs = {
        "files": attr.label_list(
            allow_empty = False,
            allow_files = True,
            mandatory = True,
        ),
        "_assert_descending_sizes":
                web_internal_python_script_label("//test:assert_descending_sizes"),
    },
    outputs = {
        "stamp_file": "assert/descending_sizes/%{name}.stamp",
    },
    implementation = _assert_descending_sizes_impl,
)

_assert_equal = rule(
    attrs = {
        "expected_file": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "actual_file": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "_assert_equal": web_internal_python_script_label("//test:assert_equal"),
    },
    outputs = {
        "stamp_file": "assert/equal/%{name}.stamp",
    },
    implementation = _assert_equal_impl,
)

_assert_valid_type = rule(
    attrs = {
        "files": attr.label(
            mandatory = True,
        ),
        "type": attr.string(
            mandatory = True,
            values = [
                "html",
                "json",
                "png",
            ]
        ),
        "_assert_valid_type": web_internal_python_script_label("//test:assert_valid_type"),
    },
    outputs = {
        "stamp_file": "assert/valid_type/%{name}.stamp",
    },
    implementation = _assert_valid_type_impl,
)

_assert_label_struct = rule(
    attrs = {
        "label": attr.label(
            mandatory = True,
        ),
        "expected_struct_string": attr.string(
            mandatory = True,
        ),
    },
    outputs = {
        "stamp_file": "assert/valid_type/%{name}.stamp",
    },
    implementation = _assert_label_struct_impl,
)

def _normalize_name(name):
    return (name
            .replace(" ", "-")
            .replace(":", "__colon__")
            .replace("\"", "__quote__")
            .replace("{", "__open-bracket__")
            .replace("}", "__close-bracket__")
            .replace("[", "__open-bracket__")
            .replace("]", "__close-bracket__"))

def assert_descending_sizes(files):
    if type(files) != "list":
        files = [ files ]

    name = "assert_descending_sizes_{files}".format(files = "-".join(files))
    name = _normalize_name(name)

    _assert_descending_sizes(
        name = name,
        files = files,
    )

def assert_equal(expected_file, actual_file):
    name = "assert_equal_{expected}_{actual}".format(expected = expected_file, actual = actual_file)
    name = _normalize_name(name)
    _assert_equal(
        name = name,
        expected_file = expected_file,
        actual_file = actual_file,
    )

def assert_valid_type(files, type):
    name = "assert_valid_type_{files}_{type}".format(files = files, type = type)
    name = _normalize_name(name)
    _assert_valid_type(
        name = name,
        files = files,
        type = type,
    )

def assert_label_struct(label, expected_struct):
    if type(expected_struct) != "dict":
        fail("expected_struct is not a dict")

    expected_struct_string = str(expected_struct)
    name = "assert_label_struct_{label}_{expected_struct}".format(
            label = label,
            expected_struct = expected_struct_string)
    name = _normalize_name(name)
    _assert_label_struct(
        name = name,
        label = label,
        expected_struct_string = expected_struct_string,
    )