# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import hashlib
import itertools
import os
import string
import zipfile

def parse_args():
    parser = argparse.ArgumentParser(description='Minifies file names of resouces in the zip')
    parser.add_argument('--in-zip', type=argparse.FileType('r'), required=True)
    parser.add_argument('--out-zip', type=argparse.FileType('w+'), required=True)
    parser.add_argument('--keep-extensions', action='store_true')
    parser.add_argument('--allow-multicase', action='store_true')
    parser.add_argument('--use-content-hash', action='store_true')
    parser.add_argument('--root-files', type=str, nargs='+', default=[])
    return parser.parse_args()

def get_extension(file_path):
    _, extension = os.path.splitext(file_path)
    return extension

def process(file, processor, buffer_size=4096):
    while True:
        data = file.read(buffer_size)
        if not data:
            break
        processor(data)

def get_name(in_zip, path, root_files, name_generator, keep_extensions, use_content_hash):
    if path in root_files:
        return path
    else:
        name = None

        if use_content_hash:
            hasher = hashlib.sha1()
            with in_zip.open(path, 'r') as zip_entry:
                process(zip_entry, lambda data: hasher.update(data))
            name = hasher.hexdigest()
        else:
            name = name_generator.next()

        if keep_extensions:
            name += get_extension(path)

        return name

def get_name_generator(allow_multicase):
    characters = string.digits + (
            string.ascii_letters if allow_multicase else string.ascii_lowercase)
    n = 1
    while True:
        for name in itertools.product(characters, repeat=n):
            yield ''.join(name)
        n += 1

def process_file(file_path, file_name_map, in_zip, out_zip, name_generator):
    contents = in_zip.read(file_path)

    for key, value in file_name_map.iteritems():
        if key in contents:
            contents = contents.replace(key, value)

    out_zip.writestr(file_name_map[file_path], contents)

def main():
    args = parse_args()
    name_generator = get_name_generator(args.allow_multicase)

    with zipfile.ZipFile(args.in_zip, mode='r') as in_zip:
        paths = set(in_zip.namelist())

        assert paths >= args.root_files

        file_name_map = {
            path: get_name(in_zip, path, args.root_files, name_generator, args.keep_extensions, args.use_content_hash)
                for path in paths }

        with zipfile.ZipFile(args.out_zip, mode='w') as out_zip:
            for path in paths:
                process_file(path, file_name_map, in_zip, out_zip, name_generator)


if __name__ == '__main__':
    main()
