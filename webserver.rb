require 'socket'
require 'pry-byebug'

require_relative 'workerthread'

class WebServer
  def server
    server = TCPServer.new('localhost', 8080)

    loop do
      puts '==クライアントの接続を待ちます=='
      socket = server.accept
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)

      thread = WorkerThread.new(socket)
      thread.run
    end
    server.close
  end
end

WebServer.new.server
