# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import hashlib

def parse_args():
    parser = argparse.ArgumentParser(description='Asserts files are the same')
    parser.add_argument('--stamp', type=argparse.FileType('w+'), required=True,
                                   help='Stamp file to record action completed')
    parser.add_argument('--files', type=argparse.FileType('r'), nargs='+', required=True)
    return parser.parse_args()

def main():
    args = parse_args()

    assert len(args.files) >= 2, 'There must be at least two files to compare'

    hash_value = None
    for file in args.files:
        with file as fp:
            hasher = hashlib.sha1()
            hasher.update(fp.read())
            hash_hex = hasher.hexdigest()
            if hash_value is None:
                hash_value = hash_hex
            else:
                assert hash_hex == hash_value, \
                        'File "{file}" does not match other hashses'.format(file=file)

    with args.stamp as stamp_file:
        stamp_file.write(str(args))

if __name__ == '__main__':
    main()
