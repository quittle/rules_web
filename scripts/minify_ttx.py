# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import itertools
import string
import time
import xml.etree.ElementTree

def parse_args():
    parser = argparse.ArgumentParser(description='Creates an ico file')
    parser.add_argument('--in-ttx', type=argparse.FileType('r'), required=True)
    parser.add_argument('--out-ttx', type=argparse.FileType('w+'), required=True)
    return parser.parse_args()

def next_name():
    characters = string.ascii_letters + string.digits
    n = 1
    while True:
        for name in itertools.product(characters, repeat=n):
            yield ''.join(name)
        n += 1

    # Rip out
    # head/tableVersion:value
    # head/fontRevision:value
    # head/created:value
    # head/modified:value
    # name - Too questionable. Leave in
    # Minify all `name`/`glyph` and `id` attributes

def replace_element_attribute_if_found(element, attribute, new_value):
    attributes = element.attrib
    if attribute in attributes:
        element.set(attribute, new_value)

def replace_element_value(element, tag, new_value):
    if element.tag == tag:
        element.set('value', new_value)

def main():
    args = parse_args()

    tree = xml.etree.ElementTree.parse(args.in_ttx)

    name_generator = next_name()

    name_map = {}
    root = tree.getroot()


    # Remove font-forge tables
    fftm = root.find('FFTM')
    if fftm is not None:
        root.remove(fftm)

    # Find glyph names
    for element in root.iter():
        attributes = element.attrib
        if 'name' in attributes:
            name = attributes['name']
            if name not in name_map :
                name_map[name] = name_generator.next()

        if 'glyph' in attributes:
            glyph = attributes['glyph']
            if glyph not in name_map :
                name_map[glyph] = name_generator.next()

    for element in root.iter():
        attributes = element.attrib
        # Rename glyphs
        replace_element_attribute_if_found(element, 'name', name_map.get(attributes.get('name')))
        replace_element_attribute_if_found(element, 'glyph', name_map.get(attributes.get('glyph')))
        # Clear dates
        epoch = time.ctime(0)
        replace_element_value(element, 'created', epoch)
        replace_element_value(element, 'modified', epoch)

    tree.write(args.out_ttx, encoding='utf-8', xml_declaration=True)

if __name__ == '__main__':
    main()