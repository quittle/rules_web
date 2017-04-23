# Copyright (c) 2017 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
from PIL import Image
import sys

def parse_args():
    parser = argparse.ArgumentParser(description='Resizes an image')
    parser.add_argument('--source', type=argparse.FileType('r'), required=True)
    parser.add_argument('--width', type=str, required=True)
    parser.add_argument('--height', type=str, required=True)
    parser.add_argument('--x-offset', type=str, required=True)
    parser.add_argument('--y-offset', type=str, required=True)
    parser.add_argument('--output', type=argparse.FileType('w+'), required=True)
    return parser.parse_args()

def parse_number(number):
    if number.endswith('%'):
        return float(float(number[:-1]) / 100)
    else:
        return int(number)

def check_bounds(number):
    if number < 0:
        print 'Argument may not be negative: %d' % number
        sys.exit(1)

    num_type = type(number)
    if num_type == float:
        if number > 1:
            print 'Percent may not be greater than 100%'
            sys.exit(1)
    elif num_type == int:
        pass
    else:
        print 'Invalid number type: %s' % num_type
        sys.exit(1)

def is_pct(number):
    return type(number) == float

def convert_dimension(source_dimen, dest_dimen):
    if is_pct(dest_dimen):
        return int(source_dimen * dest_dimen)
    else:
        return dest_dimen

def main():
    args = parse_args()

    width = parse_number(args.width)
    height = parse_number(args.height)
    x_offset = parse_number(args.x_offset)
    y_offset = parse_number(args.y_offset)

    for value in [ width, height, x_offset, y_offset ]:
        check_bounds(value)

    with args.source as input_file:
        image = Image.open(input_file)

        image_width, image_height = image.size

        width = convert_dimension(image_width, width)
        height = convert_dimension(image_height, height)
        x_offset = convert_dimension(image_width, x_offset)
        y_offset = convert_dimension(image_height, y_offset)

        if x_offset + width > image_width:
            print 'Cropped image outside bounds of source width'
            sys.exit(2)
        elif y_offset + height > image_height:
            print 'Cropped image outside bounds of source height'
            sys.exit(2)

        resized_image = image.crop((x_offset, y_offset, x_offset + width, y_offset + height))
        with args.output as output_file:
            resized_image.save(output_file, format=image.format, mode=image.mode)


if __name__ == '__main__':
    main()
