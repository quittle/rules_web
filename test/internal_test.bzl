# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//:internal.bzl",
    "dict_to_struct_",
    "merge_dicts_",
    "struct_to_dict_",
    "while_loop_",
)

def run_all_tests():
    test_merge_dicts_()
    test_dict_to_struct()
    test_struct_to_dict()
    test_while_loop()

def assert_equal(v1, v2):
    if v1 != v2:
        fail("Values were not equal (" + str(v1) + ") (" + str(v2) + ")")

def assert_str_equal(v1, v2):
    assert_equal(str(v1), str(v2))

def test_merge_dicts_():
    assert_equal(merge_dicts_({}, {}), {})

    assert_equal(merge_dicts_({"a": None}, {}), {"a": None})
    assert_equal(merge_dicts_({}, {"a": None}), {"a": None})

    assert_equal(merge_dicts_({"a": None}, {"a": 1}), {"a": 1})

    assert_equal(merge_dicts_({"a": [1]}, {"a": [2]}), {"a": [1, 2]})
    assert_equal(merge_dicts_({"a": [1]}, {"b": 2, "c": {}}), {"a": [1], "b": 2, "c": {}})

    assert_str_equal(merge_dicts_({"a": set([])}, {"a": set([1, 2])}), {"a": set([2, 1])})

def test_dict_to_struct():
    assert_str_equal(dict_to_struct_({}), struct())

    assert_str_equal(
        dict_to_struct_({
            "nested_list": [[ "a" ]],
            "set":  set([ 1, 2 ]),
            "dict": {
                "a": "b",
            }
        }),
        struct(
            nested_list = [[ "a" ]],
            set = set([ 1, 2 ]),
            dict = {
                "a": "b",
            },
        )
    )

def test_struct_to_dict():
    assert_equal(struct_to_dict_(struct()), {})

    assert_str_equal(
        struct_to_dict_(struct(
            nested_list = [[ "a" ]],
            dict_in_list = [{ "key": "value" }],
            struct_in_list = [struct(
                key = "value",
            )],
            set = set([ 1, 2 ]),
            struct = struct(
                a = "b",
            ),
        )),
        {
            "nested_list": [[ "a" ]],
            "dict_in_list": [{ "key": "value" }],
            "struct_in_list": [{
                "key": "value",
            }],
            "set":  set([ 1, 2 ]),
            "struct": {
                "a": "b",
            },
        }
    )

def incr(state):
    if type(state) == "dict":
        state["incr_calls"] = state.get("incr_calls", 0) + 1
        state["value"] += 1
    else:
        state += 1
    return state

def decr(state):
    if type(state) == "dict":
        state["decr_calls"] = state.get("decr_calls", 0) + 1
        state["value"] -= 1
    else:
        state -= 1
    return state

def is_3(state):
    if type(state) == "dict":
        state["is_3_calls"] = state.get("is_3_calls", 0) + 1
        return state["value"] == 3
    else:
        return state == 3

def test_while_loop():
    assert_equal(None, while_loop_(fail))

    assert_equal(0, while_loop_(decr, state = 3))

    assert_str_equal(
        {
            "incr_calls": 3,
            "is_3_calls": 4,
            "value": 3
        },
        while_loop_(incr, is_3, state = {"value": 0})
    )
