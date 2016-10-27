# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import zipfile

def parse_args():
    parser = argparse.ArgumentParser(description='Renames paths in a zip folder')
    parser.add_argument('--in-zip', type=argparse.FileType('r'), required=True)
    parser.add_argument('--out-zip', type=argparse.FileType('w+'), required=True)
    parser.add_argument('--path-map', type=str, nargs='+', default=[])
    return parser.parse_args()

def main():
    args = parse_args()

    assert len(args.path_map) % 2 == 0

    path_map = dict(zip(args.path_map[0::2], args.path_map[1::2]))

    with zipfile.ZipFile(args.in_zip, mode='r') as in_zip:
        for path in in_zip.namelist():
            if path not in path_map:
                path_map[path] = path


        with zipfile.ZipFile(args.out_zip, mode='w') as out_zip:
            for source, dest in path_map.iteritems():
                out_zip.writestr(dest, in_zip.read(source))

if __name__ == '__main__':
    main()