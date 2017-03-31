# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
from PIL import Image
import sys

def parse_args():
    parser = argparse.ArgumentParser(description='Resizes an image')
    parser.add_argument('--source', type=argparse.FileType('r'), required=True)
    parser.add_argument('--width', type=int)
    parser.add_argument('--height', type=int)
    parser.add_argument('--scale', type=float)
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

        width = None
        height = None
        if args.scale:
            width = int(image_width * args.scale)
            height = int(image_height * args.scale)
        else:
            width = args.width
            height = args.height

        resized_image = image.resize((width, height))
        with args.output as output_file:
            resized_image.save(output_file, format=image.format, mode=image.mode, fake='tacos')


if __name__ == '__main__':
    main()