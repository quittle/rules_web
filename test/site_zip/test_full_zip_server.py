import os
import signal
import subprocess
import time
import urllib2
import unittest

class Server():
    def __init__(self, args = []):
        self.p = subprocess.Popen(
            [os.path.join('test', 'site_zip', 'full_zip_server')] + args,
            stderr = subprocess.PIPE)
        
        # Wait for server to start up
        while self.p.stderr.readline().strip() != 'Server starting...':
            pass
    
    def __del__(self):
        if self.p is not None:
            self.stop()
            
    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        self.stop()
    
    def stop(self):
        assert self.p is not None
        
        self.p.terminate()
        
        while self.p.stderr.readline().strip() != 'Server shut down':
            pass
        
        # Close up connections to avoid hanging forever
        self.p.communicate()
        
        self.p = None

def build_url(port, path = ''):
    return 'http://0.0.0.0:{port}{path}'.format(port = port, path = path)

class TestZipServer(unittest.TestCase):
    def setUp(self):
        self.server = Server()

    def tearDown(self):
        self.server.stop()
    
    def test_happy(self):
        data = urllib2.urlopen(build_url(1234, '/data.txt')).read()
        self.assertEqual(data, 'data')
    
    def test_bad_Port(self):
        with self.assertRaises(urllib2.URLError) as cm:
            urllib2.urlopen(build_url(9999))

        self.assertEqual(cm.exception.reason.errno, 111)
        
    def test_404(self):
        for path in ('', '/', '/fake'):
            with self.assertRaises(urllib2.HTTPError) as cm:
                urllib2.urlopen(build_url(1234, path))
            self.assertEqual(cm.exception.code, 404)
    
    def test_custom_port(self):
        custom_port = 4321
        with Server(['--port', str(custom_port)]) as server:
            data = urllib2.urlopen(build_url(custom_port, '/data.txt')).read()
            self.assertEqual(data, 'data')

if __name__ == '__main__':
    unittest.main()
