# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse

def parse_args():
    parser = argparse.ArgumentParser(description='Copies a file from one location to another')
    parser.add_argument('--source', type=argparse.FileType('r'), required=True)
    parser.add_argument('--destination', type=argparse.FileType('w'), required=True)
    return parser.parse_args()

def main():
    args = parse_args()

    with args.source as source, args.destination as destination:
        destination.write(source.read())

if __name__ == '__main__':
    main()
