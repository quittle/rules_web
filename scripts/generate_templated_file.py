# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import json

from scripts import jinja_helper

def parse_args():
    parser = argparse.ArgumentParser(description='Generates a python file')
    parser.add_argument('--template', type=str, required=True)
    parser.add_argument('--config', type=json.loads, required=True)
    parser.add_argument('--out-file', type=argparse.FileType('w'), required=True)
    parser.add_argument('--pretty', action='store_true', default=True)
    return parser.parse_args()

def main():
    args = parse_args()

    jinja_helper.generate(args.template, args.config, args.out_file, args.pretty)

if __name__ == '__main__':
    main()
