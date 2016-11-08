# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

# Default methods and attributes associated with Targets. This is due to limitations in Bazel being
# unable to detect if an attribute of an object is a method or really an attribute
_DEFAULT_TARGET_STRUCT_KEYS = [
    "data_runfiles",
    "default_runfiles",
    "files",
    "files_to_run",
    "label",
    "output_group",
]

# Due to restrictions of the language, the only loop supported is a for-in loop. This huge loop is a
# substitute for a while-do loop. Make sure to terminate the loop when complete.
_LONG_LIST = 10000 * "."

# Converts a dictionary into a json-like dict, simplifying Bazel objects into strings and sets into
# lists.
# dictionary - dict - The dict to simplify
# dict - Returns a dict that contains only dicts, lists, strings, and numbers.
def simple_dict_(dictionary):
    result = {}
    stack = [ (result, key, value if type(value) != "set" else list(value))
            for key, value in dictionary.items() ]
    for i in _LONG_LIST:
        if len(stack) == 0:
            break
        obj, key, value = stack.pop()

        type_value = type(value)
        simple_value = None
        if type_value == "list":
            simple_value = []
            stack.extend([ (simple_value, None, sub_value) for sub_value in value ])
        elif type_value == "dict":
            simple_value = {}
            stack.extend([ (simple_value, sub_key, sub_value)
                    for sub_key, sub_value in value.items() ])
        elif type_value == "File":
            simple_value = value.path
        elif type_value in ["number", "string"]:
            simple_value = value
        else:
            fail("Unable to handle type: " + type_value)

        type_obj = type(obj)
        if type_obj == "dict":
            if type(key) != "string":
                fail("Key is not a string: " + type(key))
            obj[key] = simple_value
        elif type_obj == "list":
            if key != None:
                fail("Key should have been None: " + key)
            obj.append(simple_value)
        else:
            fail("Obj of invalid type: " + type_obj)

    return result

# Converts a struct to a dict
# structure - struct - The struct to convert
# dict - Returns a dict representation of the struct
def struct_to_dict_(structure):
    default_struct_methods = set(dir(struct()) + _DEFAULT_TARGET_STRUCT_KEYS)
    ret = {}
    for key in dir(structure):
        if key not in default_struct_methods:
            ret[key] = getattr(structure, key, None)
    return ret

# Converts a dict to a struct
# dictionary - dict - The dict to convert
# struct - Returns a struct representation of the dict
def dict_to_struct_(dictionary):
    return struct(**dictionary)

# Merges the two structs and returns the new, merged struct
# struct_1 - struct - The first struct to merge
# struct_2 - struct - The second struct to merge
# struct - Returns a new struct containing all the entries from the inputs. The second struct's
#          entries override the first's.
def merge_structs_(struct_1, struct_2):
    return dict_to_struct_(struct_to_dict_(struct_1) + struct_to_dict_(struct_2))

# Helper function for adding optional flags to action inputs
# flag - str - The flag for the argument. E.g. "--arg-name"
# val - bool or list - A boolean to indicate if the flag should appear or not or a list, which if
#                      non-empty will result in a list with the flag followed by the contents.
# list - Returns a list that will either be empty, contain just the flag, or contain the flag and
#        the contents of val.
def optional_arg_(flag, val):
    val_type = type(val)

    if val_type == "bool" and val:
        return [ flag ]
    elif val_type == "list" and len(val) > 0:
        return [ flag ] + val
    else:
        return []

# Helper function for copying a file from one location to another
# ctx - ctx - The context to use
# file_copy_script - executable - The file_copy executable
# source_file - File - The file to copy
# destination_file - File - The file to copy it out to
def copy_(ctx, file_copy_script, source_file, destination_file):
    if (type(ctx) != "ctx"):
        fail("ctx was not a context")
    if (type(file_copy_script) != "File"):
        fail("file_copy_script was not a file")
    if (type(source_file) != "File"):
        fail("source_file was not a file")
    if (type(destination_file) != "File"):
        fail("destination_file was not a file")

    ctx.action(
        mnemonic = "CopyFile",
        arguments = [
            "--source", source_file.path,
            "--destination", destination_file.path,
        ],
        inputs = [ file_copy_script, source_file ],
        executable = file_copy_script,
        outputs = [ destination_file ],
    )

# Adds all the transitive dependencies of resource to orig_struct and returns the new struct
# orig_struct - struct - The base struct
# resource - struct - The struct to get properties from
# A merged struct with all the resources in resource on top of orig_struct's resources
def transitive_resources_(orig_struct, resource):
    return struct(
        source_map = merge_structs_(getattr(orig_struct, "source_map", struct()),
                getattr(resource, "source_map", struct())),
        resources = getattr(orig_struct, "resources", set()) +
                getattr(resource, "resources", set()),
        css_resources = getattr(orig_struct, "css_resources", set()) +
                getattr(resource, "css_resources", set()),
        deferred_js_files = getattr(orig_struct, "deferred_js_files", set()) +
                getattr(resource, "deferred_js_files", set()),
        js_resources = getattr(orig_struct, "js_resources", set()) +
                getattr(resource, "js_resources", set()),
    )

# Helper function to define a label for a python script
# label - string - The label of the script
# Label - Returns a Label the the correct arguments
def web_internal_python_script_label(label):
    if (type(label) != "string"):
        fail("label was not a string")

    return attr.label(
        default = Label(label),
        executable = True,
        cfg = "host",
        allow_files = True,

        # single_file cannot be used while py_binary produces multiple
        # files, the binary of which is not selectable as a specific target
        # the way java_binary is
        #single_file = True,
    )

# Helper function to define a label for a tool
# label - string - The label of the tool
# Label - Returns a Label with the correct arguments
def web_internal_tool_label(label):
    if (type(label) != "string"):
        fail("label was not a string")

    return attr.label(
        default = Label(label),
        executable = True,
        cfg = "host",
        single_file = True,
        allow_files = True,
    )

# Helper function to create an action that generates a file from a jinja template
# ctx - context - The context to use
# template - File - The jinja template file
# config - dict - The args to use with the template
# out_file - File - The file generated from applying |config| to |template|
def web_internal_generate_jinja_file(ctx, template, config, out_file):
    if (type(ctx) != "ctx"):
        fail("ctx was not a context")
    if (type(template) != "File"):
        fail("template was not a File")
    if (type(config) != "dict"):
        fail("config was not a dictionary")
    if (type(out_file) != "File"):
        fail("out_file was not a File")

    ctx.action(
        mnemonic = "GeneratingFileFromJinjaTemplate",
        arguments = [
            "--template", template.path,
            "--config", str(config),
            "--out-file", out_file.path,
        ],
        inputs = [ template ],
        executable = ctx.executable._generate_jinja_file,
        outputs = [ out_file ],
    )
