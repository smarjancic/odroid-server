import http.server
import cgi
import base64
import json
import os
from urllib.parse import urlparse, parse_qs

class CustomServerHandler(http.server.BaseHTTPRequestHandler):

    def do_HEAD(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

    def do_GET(self):
        response = {}
        response['success'] = True
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

        base_path = urlparse(self.path).path
        getvars = self._parse_GET()

        response['message'] = 'Done'

        processor = RequestProcessor()
        processor.process(base_path, self.server.get_methods())

        self.wfile.write(bytes(json.dumps(response), 'utf-8'))

    def do_POST(self):
        response = {}
        response['success'] = True
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

        base_path = urlparse(self.path).path
        getvars = self._parse_GET()
        postvars = self._parse_POST()

        response['message'] = 'Done'

        processor = RequestProcessor()
        processor.process(base_path, self.server.get_methods())

        self.wfile.write(bytes(json.dumps(response), 'utf-8'))

    def _parse_POST(self):
        ctype, pdict = cgi.parse_header(self.headers.getheader('content-type'))
        if ctype == 'multipart/form-data':
            postvars = cgi.parse_multipart(self.rfile, pdict)
        elif ctype == 'application/x-www-form-urlencoded':
            length = int(self.headers.getheader('content-length'))
            postvars = cgi.parse_qs(
                self.rfile.read(length), keep_blank_values=1)
        else:
            postvars = {}

        return postvars

    def _parse_GET(self):
        getvars = parse_qs(urlparse(self.path).query)

        return getvars

class CustomHTTPServer(http.server.HTTPServer):
    methods = {}

    def __init__(self, address, handlerClass=CustomServerHandler):
        super().__init__(address, handlerClass)

    def set_methods(self):
        with open('/config/methods.json') as json_file:
            self.methods = json.load(json_file)

    def get_methods(self):
        return self.methods

class RequestProcessor():
    def process(self, path, methods):
        if path in methods:
            os.system(methods[path])
        else:
            print("Unrecognized method")

if __name__ == '__main__':
    server = CustomHTTPServer(('', 80))
    server.set_methods()
    server.serve_forever()
