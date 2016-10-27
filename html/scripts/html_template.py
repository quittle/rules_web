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
    parser.add_argument('--css-files', type=str, nargs='+', default=[])
    parser.add_argument('--deferred-js-files', type=str, nargs='+', default=[])
    parser.add_argument('--js-files', type=str, nargs='+', default=[])
    parser.add_argument('--resource-json-map', type=json.loads, default={})
    parser.add_argument('--favicons', type=str, nargs='+', default=[],
            help='A list of size and file pairs. e.g. "16 favicon-16x16.png 32 favicon-32x32.png"')
    parser.add_argument('--body', type=str, required=True)
    parser.add_argument('--output', type=argparse.FileType('w+'), required=True)
    return parser.parse_args()

def main():
    args = parse_args()

    if len(args.favicons) % 2 != 0:
        print 'Favicons must contain an even number of items'
        sys.exit(1)

    favicons = dict(zip((int(size) for size in args.favicons[0::2]), args.favicons[1::2]))

    template_path, template_filename = os.path.split(args.template)
    body_path, body_filename = os.path.split(args.body)

    config = None
    with args.config as config_file:
        config = json.load(config_file)
    config['favicons'] = favicons
    config['body'] = body_filename
    config['css_files'] = args.css_files
    config['deferred_js_files'] = args.deferred_js_files
    config['js_files'] = args.js_files
    config['resource_json_map_string'] = json.dumps(args.resource_json_map)

    env = jinja2.Environment(loader = jinja2.FileSystemLoader([template_path, body_path]))
    template = env.get_template(template_filename)
    rendered_output = template.render(config)

    with args.output as out_file:
        template.stream(config).dump(out_file)


if __name__ == '__main__':
    main()
