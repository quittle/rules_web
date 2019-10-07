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
    parser.add_argument('--inline-js-files', type=argparse.FileType('r'), nargs='+', default=[])
    parser.add_argument('--favicons', type=str, nargs='+', default=[],
            help='A list of size and file pairs. e.g. "16 favicon-16x16.png 32 favicon-32x32.png"')
    parser.add_argument('--body', type=argparse.FileType('r'), required=True)
    parser.add_argument('--output', type=argparse.FileType('w+'), required=True)
    return parser.parse_args()

def dict_extend(dictionary, key, extension):
    extension_type = type(extension)
    if extension_type == list:
        dictionary[key] = dictionary.get(key, []) + extension
    elif extension_type == set:
        dictionary[key] = dictionary.get(key, set([])) + extension
    elif extension_type == dict:
        dictionary[key] = dictionary.get(key, {})
        dictionary[key].update(extension)
    else:
        print('Unrecognized extension type: ' + str(extension_type))
        sys.exit(2)

def include_body():
    return jinja2.Markup(loader.get_source(env, ))

def main():
    args = parse_args()

    if len(args.favicons) % 2 != 0:
        print('Favicons must contain an even number of items')
        sys.exit(1)

    favicons = dict(zip((int(size) for size in args.favicons[0::2]), args.favicons[1::2]))

    template_path, template_filename = os.path.split(args.template)

    config = None
    with args.config as config_file:
        config = json.load(config_file)

    body_content = None
    with args.body as body:
        body_content = body.read()

    inline_js_contents = []
    for inline_js_file in args.inline_js_files:
        with inline_js_file as fp:
            inline_js_contents.append(fp.read())

    dict_extend(config, 'favicons', favicons)
    dict_extend(config, 'css_files', args.css_files)
    dict_extend(config, 'deferred_js_files', args.deferred_js_files)
    dict_extend(config, 'js_files', args.js_files)
    dict_extend(config, 'inline_js_files_contents', inline_js_contents)

    env = jinja2.Environment(loader = jinja2.FileSystemLoader([template_path]))
    env.globals['include_body'] = lambda: jinja2.Markup(body_content)
    template = env.get_template(template_filename)
    rendered_output = template.render(config)

    with args.output as out_file:
        template.stream(config).dump(out_file)


if __name__ == '__main__':
    main()
