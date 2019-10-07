# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import itertools
import string
import time
import xml.etree.ElementTree

PPEM_KEY = 'ppem'

def parse_args():
    parser = argparse.ArgumentParser(description='Minifies a TTX file')
    parser.add_argument('--in-ttx', type=argparse.FileType('r'), required=True)
    parser.add_argument('--out-ttx', type=argparse.FileType('wb+'), required=True)
    return parser.parse_args()

def next_name():
    characters = string.ascii_letters + string.digits
    n = 1
    while True:
        for name in itertools.product(characters, repeat=n):
            yield ''.join(name)
        n += 1

def replace_element_attribute_if_found(element, attribute, new_value):
    attributes = element.attrib
    if attribute in attributes:
        element.set(attribute, new_value)

def rename_value_from_name_map(element, key, name_map):
    name = element.attrib.get(key)
    replace_element_attribute_if_found(element, key, name_map.get(name))

def replace_element_value(element, tag, new_value):
    if element.tag == tag:
        element.set('value', new_value)

def main():
    args = parse_args()

    tree = xml.etree.ElementTree.parse(args.in_ttx)

    name_generator = next_name()

    name_map = {
        '.notdef': '.notdef', # This glyph must not be changed as it is a well-known value.
    }
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
                name_map[name] = next(name_generator)

        if 'glyph' in attributes:
            glyph = attributes['glyph']
            if glyph not in name_map :
                name_map[glyph] = next(name_generator)

    for element in root.iter():
        attributes = element.attrib
        tag = element.tag
        text = element.text

        # Rename attributes that are clearly identifiers (unlike "value" or "in")
        for attr in ['glyphName', 'name', 'glyph']:
            rename_value_from_name_map(element, attr, name_map)

        if tag in ['Glyph', 'SecondGlyph']:
            rename_value_from_name_map(element, 'value', name_map)
        elif tag == 'Substitution':
            rename_value_from_name_map(element, 'in', name_map)
            rename_value_from_name_map(element, 'out', name_map)
        elif tag == 'Ligature':
            # Components can halve multiple values delineated by commas. Example:
            # `comma,semicolon,A,seven`
            element.set('components',
                        ','.join([ name_map[component]
                            for component in attributes.get('components').split(',') ]) )
        elif tag == 'hdmxData':
            # This data is formatted in a CSS-style format, but must start with PPEM. Example
            # ```
            #   ppem: 9
            #
            #      a: 3
            #  comma: 9
            # period: 4
            #      B: 3
            # ```

            # Convert into dictionary
            values = { pair[0].strip(): pair[1].strip()
                for statement in text.strip(';').split(';') if len(statement.strip()) > 0
                    for pair in [ statement.split(':', 1) ] } # Split and store in a temp variable

            # Build into new dict to avoid overriding match values (such as the short name "m"
            # replacing the real name for the glyph "m")
            new_values = {}
            for key, value in values.items():
                if key != PPEM_KEY and key in name_map:
                    key = name_map[key]

                # Sanity check that new_values are real
                assert key not in new_values
                new_values[key] = value

            # "ppem:" must be the first item in the entry to pass an assert
            assert PPEM_KEY in new_values
            element.text = '{ppem}: {value};\n'.format(ppem=PPEM_KEY, value=new_values[PPEM_KEY])
            del new_values[PPEM_KEY]

            element.text += ';\n'.join(
                        [ key + ': ' + value
                            for key, value in new_values.items() ]
                    ) + ';'

        # Clear dates
        epoch = time.ctime(0)
        replace_element_value(element, 'created', epoch)
        replace_element_value(element, 'modified', epoch)

    tree.write(args.out_ttx, encoding='utf-8', xml_declaration=True)

if __name__ == '__main__':
    main()