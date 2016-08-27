# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import jinja2
import json
import os
import sys

def parse_args():
    parser = argparse.ArgumentParser(
            description='Builds an HTML file from a jinja file and a config json file')
    parser.add_argument('--template', type=str, required=True)
    parser.add_argument('--config', type=argparse.FileType('r'), required=True)
    parser.add_argument('--favicons', type=str, nargs='+', default=[])
    parser.add_argument('--body', type=str, required=True)
    parser.add_argument('--output', type=argparse.FileType('w+'), required=True)
    return parser.parse_args()

def main():
    args = parse_args()

    if len(args.favicons) % 2 != 0:
        print 'Favicons must contain an even number of items'
        sys.exit(1)

    favicons = dict(zip((int(size) for size in args.favicons[0::2]), args.favicons[1::2]))

    config = None
    with args.config as config_file:
        config = json.load(config_file)
    config['favicons'] = favicons
    config['body'] = args.body

    template_path, template_filename = os.path.split(args.template)
    body_path, _ = os.path.split(args.body)

    env = jinja2.Environment(loader = jinja2.FileSystemLoader([template_path, body_path]))
    template = env.get_template(template_filename)
    rendered_output = template.render(config)

    with args.output as out_file:
        template.stream(config).dump(out_file)


if __name__ == '__main__':
    main()