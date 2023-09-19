require 'socket'

socket = TCPSocket.open('localhost', 80)
request = File.open('client_send.txt').read
socket.write(request)
response = socket.recvmsg[0]

File.open('client_recv_appatch.txt', 'a') do |f|
  f.write(response)
end

socket.close
