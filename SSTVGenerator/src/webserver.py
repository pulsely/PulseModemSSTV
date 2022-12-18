from http.server import HTTPServer, BaseHTTPRequestHandler
from multiprocessing import Process

    
class Serv(BaseHTTPRequestHandler):
    def do_GET(self):
       if self.path == '/':
           self.path = '/test.html'
       try:
           file_to_open = open(self.path[1:]).read()
           self.send_response(200)
       except:
           file_to_open = "File not found"
           self.send_response(404)
       self.end_headers()
       self.wfile.write(bytes(file_to_open, 'utf-8'))


def startServer(port):
    print(">> startServer()")
    httpd = HTTPServer(('localhost', port), Serv)
    httpd.serve_forever()

def startProcess():
    process = Process(target=startServer, args=(8080, ))
    #process.daemon = True
    process.start()
    print(">> process started")
    return process


if __name__ == '__main__':
   startProcess()
