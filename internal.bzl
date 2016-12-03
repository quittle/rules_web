# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

# An important note about functions in this file. Bazel does not support recursion, so this file
# uses a loop with a stack to recurse through objects. Bazel also does not support while loops, so
# an "infinite" loop for all practical purposes with an immediate conditional-break is immediately
# used. This cannot be simplified with a function because lambdas are not supported and method
# passing is tedious due to the excess method definitions

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

def _default_while_loop_termination_case(state):
    return not bool(state)

# Performs a while loop. This method is of limited use due to the inability to define lambdas
# body - function(*):* - The body function that is called with the current state for each iteration.
#                        The return value from this method is the new state
# termination_case - function(*):bool - This method determines if the loop should continue. It
#                                          takes the current state and returns a boolean. If it
#                                          returns True, the loop terminates. Defaults to using the
#                                          inverse of the global |bool| method.
# state - * - The initial state to use. Defaults to None.
# * - Returns the final state of the loop when |termination_case| returns True.
def while_loop_(body, termination_case = _default_while_loop_termination_case, state = None):
    for _ in _LONG_LIST:
        should_terminate = termination_case(state)
        if type(should_terminate) != "bool":
            fail("termination_case must return a boolean. Returned: " + str(should_terminate))

        if should_terminate:
            return state

        state = body(state)

    fail("While loop never terminated. Final state: " + str(state))

# Converts a dictionary into a json-like dict, simplifying Bazel objects into strings and sets into
# lists.
# dictionary - dict - The dict to simplify
# dict - Returns a dict that contains only dicts, lists, strings, and numbers.
def simple_dict_(dictionary):
    result = {}
    stack = [ (result, key, list(value) if type(value) == "set" else value)
            for key, value in dictionary.items() ]
    for i in _LONG_LIST:
        if len(stack) == 0:
            break
        container, key, value = stack.pop()

        type_value = type(value)
        simple_value = None
        if type_value == "list":
            simple_value = []
            stack.extend([ (simple_value, None, sub_value) for sub_value in value ])
        elif type_value == "dict":
            simple_value = {}
            stack.extend([ (simple_value, sub_key, sub_value)
                    for sub_key, sub_value in value.items() ])
        elif type_value == "struct":
            simple_value = {}
            stack.extend([ (simple_value, sub_key, sub_value)
                    for sub_key, sub_value in struct_to_dict_(value).items() ])
        elif type_value == "File":
            simple_value = value.path
        elif type_value in ["number", "string"]:
            simple_value = value
        else:
            fail("Unable to handle type: " + type_value)

        type_container = type(container)
        if type_container == "dict":
            if type(key) != "string":
                fail("Key is not a string: " + type(key))
            container[key] = simple_value
        elif type_container == "list":
            if key != None:
                fail("Key should have been None: " + key)
            container.append(simple_value)
        else:
            fail("Container of invalid type: " + type_container)

    return result

# Gets the entries in |structure| that are not default values
# structure - (struct|Target) - The struct or target to get entries from
# list of strings - Returns a list of keys in |structure| that are not added by default
def _get_struct_entries(structure):
    structure_type = type(structure)
    if structure_type not in ["struct", "Target"]:
        fail("Expected a struct or Target, but got " + structure_type)

    keys = dir(structure)
    for key in dir(struct()) + _DEFAULT_TARGET_STRUCT_KEYS:
        if key in keys:
            keys.remove(key)
    return keys

# Converts a struct to a dict along with all nested structs.
# structure - (struct|Target) - The struct or target to convert
# dict - Returns a dict representation of the struct
def struct_to_dict_(structure):
    structure_type = type(structure)
    if structure_type not in [ "struct", "Target" ]:
        fail("Expected a struct or Target, but got " + structure_type)

    contents = _get_struct_entries(structure)

    result = {}
    stack = [ (result, entry, getattr(structure, entry)) for entry in contents ]
    for i in _LONG_LIST:
        if len(stack) == 0:
            break
        container, key, value = stack.pop()

        new_value = value

        type_value = type(value)
        if type_value == "struct":
            new_value = {}
            stack.extend([ (new_value, entry, getattr(value, entry))
                    for entry in _get_struct_entries(value) ])
        elif type_value == "dict":
            new_value = {}
            stack.extend([ (new_value, sub_key, sub_value)
                    for sub_key, sub_value in value.items() ])
        elif type_value == "list":
            new_value = []
            stack.extend([ (new_value, None, sub_value) for sub_value in value ])
        # No need to worry about sets, which aren't mutable, because they cannot contain mutable
        # items or sets. Even though they can contain structs, the dicts they'd be converted to
        # wouldn't be allowed inside. Then if those structs were ignored, it wouldn't matter anyway
        # as nothing would need to be changed inside the set so no need to loop through the set's
        # contents.

        if key != None:
            container[key] = new_value
        elif type(container) == "list":
            container.append(new_value)
        else:
            fail("Unexpected container type: " + type(container))

    return result

# Converts a dict to a struct, without converting nested dicts. Note that this is not a complete
# reverse of struct_to_dict_ as it will not convert deeply nested dicts.
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
    return dict_to_struct_(merge_dicts_(struct_to_dict_(struct_1), struct_to_dict_(struct_2)))

# Returns |value| if it is not None, otherwise returns |default|.
def _default_none(value, default):
    return value if value != None else default

# Merges two dicts, overriding methods
def merge_dicts_(dict_1, dict_2):
    result = {}
    # First item needs to be inserted last so that it overrides values from the second
    stack = [ (result, (None, None), key, value)
            for key, value in dict_2.items() + dict_1.items() ]
    for i in _LONG_LIST:
        if len(stack) == 0:
            break
        # parent is the parent of container and parent_key is the key for parent that accesses
        # container.
        container, (parent, parent_key), key, value = stack.pop()

        type_container = type(container)
        type_value = type(value)

        # The current value for the same key in the container being merged into. This is to enable
        # merging into already generated containers that might be referenced in the stack.
        pre_filled_value = (
            None if type_value not in ["dict", "list", "set", "struct"] else
            container[key] if type_container == "dict" and key in container else
            list(container)[list(container).index(value)]
                    if type_container in ["list", "set"] and value in container else
            getattr(container, key) if type_container == "struct" else
            None
        )

        simple_value = None
        if type_value == "list":
            simple_value = _default_none(pre_filled_value, [])
            stack.extend([ (simple_value, (container, key), None, sub_value)
                    for sub_value in value ])
        elif type_value == "set":
            simple_value = _default_none(pre_filled_value, set([]))
            stack.extend([ (simple_value, (container, key), None, sub_value)
                    for sub_value in value ])
        elif type_value == "dict":
            simple_value = _default_none(pre_filled_value, {})
            stack.extend([ (simple_value, (container, key), sub_key, sub_value)
                    for sub_key, sub_value in value.items() ])
        elif type_value == "struct":
            simple_value = _default_none(pre_filled_value, {}) # Convert this out of laziness
            stack.extend([ (simple_value, (container, key), sub_key, sub_value)
                    for sub_key, sub_value in struct_to_dict_(value).items() ])
        else:
            simple_value = value

        if type_container == "dict":
            if type(key) != "string":
                fail("Key is not a string: " + type(key))
            container[key] = simple_value
        elif type_container == "list":
            if key != None:
                fail("Key should have been None: " + key)
            container.append(simple_value)
        elif type_container == "set":
            if key != None:
                fail("Key should have been None: " + key)
            # Sets are immutable so a new one needs to be created and inserted into the parent. This
            # can't chain because sets can't contain mutable objects or other sets.
            parent[parent_key] += set([ simple_value ])
        else:
            fail("Container of invalid type: " + type_container)

    return result

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
# resource - dict like object - The dict to get properties from
# opt_ignore_types - list of str - An optional list of types to leave out of the returned struct
# A merged struct with all the resources in resource on top of orig_struct's resources
def transitive_resources_(orig_struct, resource, opt_ignore_types=[]):
    if type(orig_struct) != "struct":
        fail("orig_struct is not a struct")
    if type(opt_ignore_types) != "list":
        fail("opt_ignore_types is not a list")

    return struct(
        source_map = merge_dicts_(getattr(orig_struct, "source_map", {}),
                getattr(resource, "source_map", {}) if "source_map" not in opt_ignore_types else {}),
        resources = getattr(orig_struct, "resources", set()) +
                (getattr(resource, "resources", set()) if "resources" not in opt_ignore_types else set()),
        css_resources = getattr(orig_struct, "css_resources", set()) +
                (getattr(resource, "css_resources", set()) if "css_resources" not in opt_ignore_types else set()),
        deferred_js_resources = getattr(orig_struct, "deferred_js_resources", set()) +
                (getattr(resource, "deferred_js_resources", set()) if "deferred_js_resources" not in opt_ignore_types else set()),
        js_resources = getattr(orig_struct, "js_resources", set()) +
                (getattr(resource, "js_resources", set()) if "js_resources" not in opt_ignore_types else set()),
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
