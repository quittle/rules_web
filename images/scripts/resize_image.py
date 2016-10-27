# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import Image
import sys

def parse_args():
    parser = argparse.ArgumentParser(description='Resizes an image')
    parser.add_argument('--source', type=argparse.FileType('r'), required=True)
    parser.add_argument('--width', type=int, required=True)
    parser.add_argument('--height', type=int, required=True)
    parser.add_argument('--output', type=argparse.FileType('w+'), required=True)
    parser.add_argument('--allow-upsizing', action='store_true', default=False)
    parser.add_argument('--allow-stretching', action='store_true', default=False)
    return parser.parse_args()

def main():
    args = parse_args()

    with args.source as input_file:
        image = Image.open(input_file)
        image_width, image_height = image.size

        if not args.allow_upsizing and (args.width > image_width or args.height > image_height):
            print 'Image upsizing not allowed'
            sys.exit(1)

        if not args.allow_stretching and (args.width / args.height) != (image_width / image_height):
            print 'Image stretching not allowed'
            sys.exit(2)

        resized_image = image.resize((args.width, args.height))
        with args.output as output_file:
            resized_image.save(output_file, format=image.format)


if __name__ == '__main__':
    main()