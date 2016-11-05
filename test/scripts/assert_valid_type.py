# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
from HTMLParser import HTMLParser
import json
import os
from PIL import Image

def parse_args():
    parser = argparse.ArgumentParser(description='Asserts files are valid')
    parser.add_argument('--stamp', type=argparse.FileType('w+'), required=True,
                                   help='Stamp file to record action completed')
    parser.add_argument('--files', type=argparse.FileType('rb'), nargs='+', required=True)
    parser.add_argument('--type', type=str, choices=['html', 'json','png'], required=True)
    return parser.parse_args()

# This is not a great parser. It does not support strict parsing
def validate_html(file):
    parser = HTMLParser()
    parser.feed(file.read())
    parser.close()

def validate_json(file):
    # Throws an exception if not valid JSON
    json.load(file)

def validate_image(file):
    Image.open(file).verify()

def validate_png(file):
    validate_image(file)
    assert Image.open(file).format == 'PNG'

def main():
    args = parse_args()

    file_type = args.type

    for file in args.files:
        with file as fp:
            if file_type == 'html':
                validate_html(fp)
            elif file_type == 'json':
                validate_json(fp)
            elif file_type == 'png':
                validate_png(fp)

    with args.stamp as stamp_file:
        stamp_file.write(str(args))

if __name__ == '__main__':
    main()
