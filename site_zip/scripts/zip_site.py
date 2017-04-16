# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import json
import zipfile

def parse_args():
    parser = argparse.ArgumentParser(
            description='Detects and zips all the required files for a site together')
    parser.add_argument('--output', type=argparse.FileType('w+'), required=True)
    parser.add_argument('--root-files', type=str, nargs='+', default=[])
    parser.add_argument('--resources', type=str, nargs='+', default=[])
    parser.add_argument('--source-map', type=json.loads, default={})
    return parser.parse_args()

def process_file(file_path, out_zip, source_map, unused_resources, used_resources=None):
    used_resources = used_resources or set()
    assert unused_resources.isdisjoint(used_resources)

    real_resource_path = source_map.get(file_path, file_path)
    out_zip.write(real_resource_path, file_path)

    contents = None
    with open(file_path, 'rb') as file:
        contents = file.read()

    for resource in unused_resources.copy():
        if resource in unused_resources and resource in contents:
            unused_resources.remove(resource)
            used_resources.add(resource)
            process_file(resource, out_zip, source_map, unused_resources, used_resources)

    return used_resources

def main():
    args = parse_args()

    with zipfile.ZipFile(args.output, mode='w') as out_zip:
        for page in args.root_files:
            process_file(page, out_zip, args.source_map, set(args.resources))


if __name__ == '__main__':
    main()
