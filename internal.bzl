# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

load("@bazel_toolbox//collections:collections.bzl",
    "merge_dicts",
)

# Returns |value| if it is not None, otherwise returns |default|.
def _default_none(value, default):
    return value if value != None else default

# Helper function for adding optional flags to action inputs
# flag - str - The flag for the argument. E.g. "--arg-name"
# val - bool or list or * - A boolean to indicate if the flag should appear or not or a list, which if
#                      non-empty will result in a list with the flag followed by the contents.
# list - Returns a list that will either be empty, contain just the flag, or contain the flag and
#        the contents of val.
def optional_arg_(flag, val):
    val_type = type(val)

    if val_type == "bool":
        if val:
            return [ flag ]
    elif val_type == "list":
        if len(val) > 0:
            return [ flag ] + [ str(v) for v in val ]
    elif val != None:
        return [ flag, str(val) ]

    return []

# Adds all the transitive dependencies of resource to orig_struct and returns the new struct
# orig_struct - struct - The base struct
# resource - dict like object - The dict to get properties from
# opt_ignore_types - list of str - An optional list of types to leave out of the returned struct
# A merged struct with all the resources in resource on top of orig_struct's resources
def transitive_resources_(orig_struct, resource, opt_ignore_types=[]):
    if type(orig_struct) != "struct":
        fail("orig_struct is not a struct")
    if type(opt_ignore_types) != "list":
        fail("opt_ignore_types is not a list")

    return struct(
        source_map = merge_dicts(getattr(orig_struct, "source_map", {}),
                getattr(resource, "source_map", {}) if "source_map" not in opt_ignore_types else {}),
        resources = getattr(orig_struct, "resources", depset()) +
                (getattr(resource, "resources", depset()) if "resources" not in opt_ignore_types else depset()),
        css_resources = getattr(orig_struct, "css_resources", depset()) +
                (getattr(resource, "css_resources", depset()) if "css_resources" not in opt_ignore_types else depset()),
        deferred_js_resources = getattr(orig_struct, "deferred_js_resources", depset()) +
                (getattr(resource, "deferred_js_resources", depset()) if "deferred_js_resources" not in opt_ignore_types else depset()),
        js_resources = getattr(orig_struct, "js_resources", depset()) +
                (getattr(resource, "js_resources", depset()) if "js_resources" not in opt_ignore_types else depset()),
    )
