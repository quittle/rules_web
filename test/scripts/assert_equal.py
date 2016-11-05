# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import difflib
import os

# Resets color formatting
COLOR_END = '\33[0m'
# Modifies characters or color
COLOR_BOLD = '\33[1m'
COLOR_DISABLED = '\33[02m' # Mostly just means darker
# Sets the text color
COLOR_GREEN = '\33[32m'
COLOR_YELLOW = '\33[33m'
COLOR_RED = '\33[31m'

def parse_args():
    parser = argparse.ArgumentParser(description='Asserts files are the same')
    parser.add_argument('--stamp', type=argparse.FileType('w+'), required=True,
                                   help='Stamp file to record action completed')
    parser.add_argument('--files', type=argparse.FileType('r'), nargs='+', required=True)
    return parser.parse_args()

def color_diff(text_a, text_b):
    """
        Compares two pieces of text and returns a tuple
        The first value is a colorized diff of the texts.
        The second value is a boolean, True if there was a diff, False if there wasn't.
    """
    sequence_matcher = difflib.SequenceMatcher(None, text_a, text_b)
    colorized_diff = ''
    diff = False
    for opcode, a0, a1, b0, b1 in sequence_matcher.get_opcodes():
        if opcode == 'equal':
            colorized_diff += sequence_matcher.a[a0:a1]
        elif opcode == 'insert':
            colorized_diff += COLOR_BOLD + COLOR_GREEN + sequence_matcher.b[b0:b1] + COLOR_END
            diff = True
        elif opcode == 'delete':
            colorized_diff += COLOR_BOLD + COLOR_RED + sequence_matcher.a[a0:a1] + COLOR_END
            diff = True
        elif opcode == 'replace':
            colorized_diff += (COLOR_BOLD + COLOR_YELLOW + sequence_matcher.a[a0:a1] +
                               COLOR_DISABLED + sequence_matcher.b[b0:b1] + COLOR_END)
            diff = True
        else:
            raise RuntimeError, "unexpected opcode"
    return colorized_diff, diff

def main():
    args = parse_args()

    files = args.files

    assert len(files) >= 2, 'There must be at least two files to compare'

    differ = difflib.Differ()
    for i in xrange(len(files) - 1):
        file_a = files[i].read()
        file_b = files[i + 1].read()
        files[i + 1].seek(0) # Only bother resetting the last one as it will be re-used
        diff, problem = color_diff(file_a, file_b)
        assert not problem, 'File {a} does not match {b}:{newline}{diff}'.format(
                a = files[i].name,
                b = files[i + 1].name,
                newline = os.linesep,
                diff = diff)

    with args.stamp as stamp_file:
        stamp_file.write(str(args))

if __name__ == '__main__':
    main()
