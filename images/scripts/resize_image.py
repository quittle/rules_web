# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
from PIL import Image
import sys

def parse_args():
    parser = argparse.ArgumentParser(description='Resizes an image')
    parser.add_argument('--source', type=argparse.FileType('rb'), required=True)
    parser.add_argument('--width', type=int)
    parser.add_argument('--height', type=int)
    parser.add_argument('--scale', type=float)
    parser.add_argument('--output', type=argparse.FileType('wb'), required=True)
    parser.add_argument('--allow-upsizing', action='store_true', default=False)
    parser.add_argument('--allow-stretching', action='store_true', default=False)
    return parser.parse_args()

def main():
    args = parse_args()

    with args.source as input_file:
        image = Image.open(input_file)
        image_width, image_height = image.size

        if not args.allow_upsizing and (args.width > image_width or args.height > image_height):
            print('Image upsizing not allowed')
            sys.exit(1)

        if not args.allow_stretching and (args.width / args.height) != (image_width / image_height):
            print('Image stretching not allowed ' + str(args.width) + ' ' + str(args.height) + ' ' + str(image_width) + ' ' + str(image_height))
            sys.exit(2)

        width = None
        height = None
        if args.scale:
            width = int(image_width * args.scale)
            height = int(image_height * args.scale)
        elif args.width and not args.height:
            width = args.width
            height = int(image_height * (width / float(image_width)))
        elif args.height and not args.width:
            height = args.height
            width = int(image_width * (height / float(image_height)))
        else:
            width = args.width
            height = args.height

        resized_image = image.resize((width, height), resample=Image.LANCZOS)
        with args.output as output_file:
            resized_image.save(output_file, format=image.format, mode=image.mode)


if __name__ == '__main__':
    main()
