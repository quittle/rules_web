# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import jinja2
import json
import os
import sys

def parse_args():
    parser = argparse.ArgumentParser(
            description='Generates a python wrapper script that deploys a website to S3')
    parser.add_argument('--bucket', type=str, required=True)
    parser.add_argument('--deployment-jinja-template', type=str, required=True)
    parser.add_argument('--generated-file', type=argparse.FileType('w'), required=True)
    parser.add_argument('--cache-durations', type=json.loads, required=True)
    parser.add_argument('--content-types', type=json.loads, required=True)
    parser.add_argument('--path-redirects', type=json.loads, required=True)
    parser.add_argument('--website-zip', type=str, required=True)
    return parser.parse_args()

def main():
    args = parse_args()

    config = {
        'bucket': args.bucket,
        'cache_durations': json.dumps(args.cache_durations),
        'content_types': json.dumps(args.content_types),
        'path_redirects': json.dumps(args.path_redirects),
        'website_zip': os.path.realpath(args.website_zip),
    }

    template_path, template_filename = os.path.split(args.deployment_jinja_template)

    env = jinja2.Environment(loader = jinja2.FileSystemLoader([template_path]))
    template = env.get_template(template_filename)
    template.stream(config).dump(args.generated_file)

if __name__ == '__main__':
    main()
