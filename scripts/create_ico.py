# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
from PIL import Image
import sys

# BUG: Currently broken

def parse_args():
    parser = argparse.ArgumentParser(description='Creates an ico file')
    parser.add_argument('--source', type=argparse.FileType('r'), required=True)
    parser.add_argument('--sizes', type=int, nargs='+', required=True)
    parser.add_argument('--output', type=argparse.FileType('w+'), required=True)
    parser.add_argument('--allow-upsizing', action='store_true', default=False)
    return parser.parse_args()

def main():
    args = parse_args()

    with args.source as input_file:
        image = Image.open(input_file)
        image_width, image_height = image.size
        max_size = max(args.sizes)

        if image_width != image_height:
            print 'Source image is not square'
            sys.exit(1)

        if not args.allow_upsizing and max_size > image_width:
            print 'Image upsizing not allowed'
            sys.exit(2)

        with args.output as output_file:
            # This will result in an error as PIL does not support saving ICOs, just reading them.
            image.save(output_file, format='ICO', sizes=zip(args.sizes, args.sizes))


if __name__ == '__main__':
    main()