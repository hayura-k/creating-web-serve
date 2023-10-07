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

  private

    def parse_http_request(request)
      request_line, remain = request.split("\r\n", 2)
      request_header, request_body = remain.split("\r\n\r\n", 2)
      method, path, http_version = request_line.split(' ')
      [method, path, http_version, request_header, request_body]
    end

    def create_response_header(path, response_body)
      content_type = create_content_type(path)

      response_header = "#{Time.now.strftime("%a, %d %b %Y %H:%M:%S GMT") + "\r\n"}"
      response_header += "Host: HenaServer/0.1\r\n"
      response_header += "Content-Length: #{response_body.bytesize}\r\n"
      response_header += "Connection: Close\r\n"
      response_header += "Content-Type: #{content_type}\r\n"

      response_header
    end

    def create_content_type(path)
      ext = path.split('.')[-1]
      MIME_TYPES[ext.to_sym]
    end
end

WebServer.new.server
