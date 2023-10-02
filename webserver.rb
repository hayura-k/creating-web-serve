require 'socket'

server = TCPServer.new('localhost', 8080)
p server

socket = server.accept
socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)

response_body = "<html><body><h1>It works!</h1></body></html>"
response_body_length = response_body.bytesize

response_line = "HTTP/1.1 200 OK\r\n"

response_header = "#{Time.now.strftime("%a, %d %b %Y %H:%M:%S GMT") + "\r\n"}"
response_header += "Host: HenaServer/0.1\r\n"
response_header += "Content-Length: #{response_body_length}\r\n"
response_header += "Connection: Close\r\n"
response_header += "Content-Type: text/html\r\n"

response = (response_line + response_header + "\r\n" + response_body).b

socket.send(response, 0)

socket.close
server.close
