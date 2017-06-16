# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import jinja2
import json
import os
import sys

TEMPLATE = [ 'deploy', 'templates', 'execute_script_wrapper.py.jinja2' ]

def parse_args():
    parser = argparse.ArgumentParser(
            description='Generates a python wrapper script that runs an executable to support ' +
                        'bazel run of a binary with arguments')
    parser.add_argument('--executable', type=str, required=True)
    parser.add_argument('--arguments', type=list, default=[])
    parser.add_argument('--generated-file', type=argparse.FileType('w'), required=True)
    return parser.parse_args()

def main():
    args = parse_args()

    config = {
        'executable_path': ,
        'arguments': args.arguments,
    }

    template_path = TEMPLATE[:-1]
    template_filename = TEMPLATE[-1:]

    env = jinja2.Environment(loader = jinja2.FileSystemLoader([template_path]))
    template = env.get_template(template_filename)
    template.stream(config).dump(args.generated_file)

if __name__ == '__main__':
    main()
