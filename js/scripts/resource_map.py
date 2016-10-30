# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import json
import os

def parse_args():
    parser = argparse.ArgumentParser(description='Builds a resource map for javascirpt')
    parser.add_argument('--constant-name', type=str, required=True)
    parser.add_argument('--path-map', type=json.loads, required=True)
    parser.add_argument('--output', type=argparse.FileType('w+'), required=True)
    return parser.parse_args()

def main():
    args = parse_args()

    path_object = {}
    # Loop over the short and full paths
    for short_path, full_path in args.path_map.items():
        # Create a list of each folder in the short path
        path_list = short_path.split(os.sep)
        # Loop over all the items except the last (the file)
        cur_obj = path_object
        for item in path_list[:-1]:
            # Create a new entry in the tree if it doesn't exist
            cur_obj = cur_obj.setdefault(item, {})
        # Add the file at the very end
        cur_obj[path_list[-1]] = full_path

    with args.output as out_file:
        out_file.write('const {name} = {value};'.format(name=args.constant_name,
                                                        value=json.dumps(path_object)))

if __name__ == '__main__':
    main()
