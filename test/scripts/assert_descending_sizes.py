# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import os

def parse_args():
    parser = argparse.ArgumentParser(description='Asserts files are the same')
    parser.add_argument('--stamp', type=argparse.FileType('w+'), required=True,
                                   help='Stamp file to record action completed')
    parser.add_argument('--files', type=str, nargs='+', required=True)
    return parser.parse_args()

def main():
    args = parse_args()

    files = args.files

    assert len(files) >= 2, "At least 2 files must be passed in"

    for i in range(1, len(files)):
        larger_file = files[i - 1]
        smaller_file = files[i]
        assert os.stat(larger_file).st_size > os.stat(smaller_file).st_size, \
                'Smaller {small}, Larger {large}'.format(small = smaller_file, large = larger_file)

    with args.stamp as stamp_file:
        stamp_file.write(str(args))

if __name__ == '__main__':
    main()
