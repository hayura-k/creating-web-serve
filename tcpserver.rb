require 'socket'

server = TCPServer.new('localhost', 8080)
p server

socket = server.accept
socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
buf = socket.recvmsg[0]
File.open('client_recv.txt', 'a') { |f| f.write(buf) }

socket.sendmsg(File.read('client_recv_appatch.txt'))

socket.close
server.close
