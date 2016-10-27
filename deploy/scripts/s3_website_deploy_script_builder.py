# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import jinja2
import os
import sys

def parse_args():
    parser = argparse.ArgumentParser(
            description='Generates a python wrapper script that deploys a website to S3')
    parser.add_argument('--aws-access-key', type=str, required=True)
    parser.add_argument('--aws-secret-key', type=str, required=True)
    parser.add_argument('--bucket', type=str, required=True)
    parser.add_argument('--deploy-executable', type=str, required=True)
    parser.add_argument('--deployment-jinja-template', type=str, required=True)
    parser.add_argument('--generated-file', type=argparse.FileType('w'), required=True)
    parser.add_argument('--website-zip', type=str, required=True)
    return parser.parse_args()

def main():
    args = parse_args()

    config = {
        'aws_access_key': args.aws_access_key,
        'aws_secret_key': args.aws_secret_key,
        'bucket': args.bucket,
        'deploy_executable': os.path.abspath(args.deploy_executable),
        'website_zip': os.path.abspath(args.website_zip),
    }

    template_path, template_filename = os.path.split(args.deployment_jinja_template)

    env = jinja2.Environment(loader = jinja2.FileSystemLoader([template_path]))
    template = env.get_template(template_filename)
    template.stream(config).dump(args.generated_file)

if __name__ == '__main__':
    main()
