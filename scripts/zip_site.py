# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import zipfile

def parse_args():
    parser = argparse.ArgumentParser(
            description='Detects and zips all the required files for a site together')
    parser.add_argument('--output', type=argparse.FileType('w+'), required=True)
    parser.add_argument('--root-files', type=str, nargs='+', default=[])
    parser.add_argument('--resources', type=str, nargs='+', default=[])
    return parser.parse_args()

def process_file(file_path, out_zip, unused_resources, used_resources=None):
    used_resources = used_resources or set()
    assert unused_resources.isdisjoint(used_resources)

    out_zip.write(file_path)

    contents = None
    with open(file_path, 'rb') as file:
        contents = file.read()

    for resource in unused_resources.copy():
        if resource in unused_resources and resource in contents:
            unused_resources.remove(resource)
            used_resources.add(resource)
            process_file(resource, out_zip, unused_resources, used_resources)

    return used_resources

def main():
    args = parse_args()

    with zipfile.ZipFile(args.output, mode='w') as out_zip:
        for page in args.root_files:
            process_file(page, out_zip, set(args.resources))


if __name__ == '__main__':
    main()