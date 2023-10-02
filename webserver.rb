require 'socket'

server = TCPServer.new('localhost', 8080)
p server

# 静的配信するファイルを置くディレクトリ
STATIC_ROOT = __dir__ + '/' + Dir.glob('static')[0]

socket = server.accept
socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
request = socket.recv(4096)
request_line, remain = request.split("\r\n", 2)
request_header, response_body = remain.split("\r\n\r\n", 2)
method, path, http_version = request_line.split(' ')

begin
  response_body = File.read(STATIC_ROOT + path)
  response_line = "HTTP/1.1 200 OK\r\n"
rescue Errno::EISDIR
  response_body = "<html><body><h1>404 Not Found</h1></body></html>"
  response_line = "HTTP/1.1 404 Not Found\r\n"
end

response_body_length = response_body.bytesize

response_header = "#{Time.now.strftime("%a, %d %b %Y %H:%M:%S GMT") + "\r\n"}"
response_header += "Host: HenaServer/0.1\r\n"
response_header += "Content-Length: #{response_body_length}\r\n"
response_header += "Connection: Close\r\n"
response_header += "Content-Type: text/html\r\n"

response = (response_line + response_header + "\r\n" + response_body).b

socket.send(response, 0)

socket.close
server.close
