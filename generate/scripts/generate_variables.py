# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import collections
import json
import os
import sys

def stringify_css(json):
    if isinstance(json, list):
        return ('[' +
                ', '.join(stringify_css(value) for value in json) +
                ']')
    elif isinstance(json, dict):
        return ('{' +
                ', '.join(key + ': ' + stringify_css(value) for key, value in json.iteritems()) +
                '}')
    elif isinstance(json, bool):
        return 'true' if json else 'false'
    else:
        return str(json)

def stringify_scss(json):
    if isinstance(json, list):
        return ('(' +
                ', '.join(stringify_scss(value) for value in json) +
                ')')
    elif isinstance(json, dict):
        return ('(' +
                ', '.join(stringify_scss(key) + ': ' + stringify_scss(value) for key, value in json.iteritems()) +
                ')')
    elif isinstance(json, bool):
        return 'true' if json else 'false'
    elif isinstance(json, unicode):
        return '\'' + str(json) + '\''
    else:
        return str(json)

class VariableWriter:
    def __init__(self, file, config):
        self._file = file
        self._config = config

    def write(self):
        if self.uses_iteration():
            for key, value in self._config.iteritems():
                self._file.write(self.write_iteration(key, value))
        else:
            self._file.write(self.write_whole(config))

    def write_iteration(self, key, value):
        raise 'Unsported write'

    def write_whole(self, config):
        raise 'Unsported write'

    def uses_iteration(self):
        return True

class CSSVariableWriter(VariableWriter):
    def write_iteration(self, key, value):
        return ':root {{ --{key}: {value}; }}\n'.format(key = key, value = stringify_css(value))

class JSVariableWriter(VariableWriter):
    def write_iteration(self, key, value):
        return 'var {key} = {value};\n'.format(key = key, value = json.dumps(value))

class SCSSVariableWriter(VariableWriter):
    def write_iteration(self, key, value):
        return '${key}: {value};\n'.format(key = key, value = stringify_scss(value))

def parse_args():
    parser = argparse.ArgumentParser(description='Generates variable mappings in various languages')
    parser.add_argument('--config', type=argparse.FileType('r'), required=True)
    parser.add_argument('--js-out', type=argparse.FileType('w+'))
    parser.add_argument('--css-out', type=argparse.FileType('w+'))
    parser.add_argument('--scss-out', type=argparse.FileType('w+'))
    return parser.parse_args()

def main():
    args = parse_args()

    if not args.js_out and not args.css_out and not args.scss_out:
        print 'Must specify at least on out file'
        sys.exit(1)

    config = None
    with args.config as config_file:
        config = json.load(config_file, encoding='ascii', object_pairs_hook=collections.OrderedDict)

    assert all(isinstance(key, basestring) for key in config.iterkeys()), 'Expected all keys to be strings'

    if args.js_out:
        JSVariableWriter(args.js_out, config).write()
    if args.css_out:
        CSSVariableWriter(args.css_out, config).write()
    if args.scss_out:
        SCSSVariableWriter(args.scss_out, config).write()

if __name__ == '__main__':
    main()
