# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import argparse
import http.server
import zipfile

class ZipRequestHandler(http.server.BaseHTTPRequestHandler):
    def do_HEAD(s):
        s.send_response(200)
        s.send_header("Content-type", "text/html")
        s.end_headers()

    def do_GET(self):
        try:
            info = self.server.zip.open(self.path[1:])
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(info.read())
        except KeyError:
            self.send_response(404)
        return


def parse_args():
    parser = argparse.ArgumentParser(
            description='Serves a zip file as a local HTTP server')
    parser.add_argument('--zip', type=str, required=True)
    parser.add_argument('--port', type=int, default=80)
    parser.add_argument('--index', type=str, default='/index.html')
    return parser.parse_args()

def main():
    args = parse_args()

    server = http.server.HTTPServer(('localhost', args.port), ZipRequestHandler)
    server.zip = zipfile.ZipFile(args.zip)
    server.serve_forever()


if __name__ == '__main__':
    main()