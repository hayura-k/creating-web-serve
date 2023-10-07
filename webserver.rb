require 'socket'
require 'pry-byebug'

server = TCPServer.new('localhost', 8080)

# 静的配信するファイルを置くディレクトリ
STATIC_ROOT = __dir__ + '/' + Dir.glob('static')[0]

MIME_TYPES = {
  html: "text/html",
  css: "text/css",
  png: "image/png",
  jpg: "image/jpg",
  gif: "image/gif",
}

#TODO: 改修がしにくすぎるためリファクタする必要あり。
while true
  puts '==クライアントの接続を待ちます=='
  socket = server.accept
  socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)

  begin
    request = socket.recv(4096)
    request_line, remain = request.split("\r\n", 2)
    request_header, response_body = remain.split("\r\n\r\n", 2)
    method, path, http_version = request_line.split(' ')


    if path == '/now'
      response_body = <<~EOS
      <html>
      <body>
        <h1>Now: "#{Time.now}"</h1>
      </body>
      </html>
      EOS

      # Content-Typeを指定
      content_type = "text/html"
      # レスポンスラインを生成
      response_line = "HTTP/1.1 200 OK\r\n"
    else
      begin
      response_body = File.read(STATIC_ROOT + path)
      response_line = "HTTP/1.1 200 OK\r\n"

      ext = path.split('.')[-1]
      content_type = MIME_TYPES[ext.to_sym]

      rescue Errno::EISDIR
        response_body = "<html><body><h1>404 Not Found</h1></body></html>"
        response_line = "HTTP/1.1 404 Not Found\r\n"

        ext = path.split('.')[-1]
        content_type = MIME_TYPES[ext.to_sym]
      end
    end

    response_header = "#{Time.now.strftime("%a, %d %b %Y %H:%M:%S GMT") + "\r\n"}"
    response_header += "Host: HenaServer/0.1\r\n"

    response_body_length = response_body.bytesize
    response_header += "Content-Length: #{response_body_length}\r\n"
    response_header += "Connection: Close\r\n"
    response_header += "Content-Type: #{content_type}\r\n"

    response = (response_line + response_header + "\r\n" + response_body).b

    puts '==レスポンスを送信します=='
    socket.send(response, 0)
  rescue => exception
    puts '==サーバーが終了しました=='
    puts exception
  ensure
    puts '==socketのclose=='
    socket.close
  end
end

server.close

class WebServer
  # 静的配信するファイルを置くディレクトリ
  STATIC_ROOT = __dir__ + '/' + Dir.glob('static')[0]

  MIME_TYPES = {
    html: "text/html",
    css: "text/css",
    png: "image/png",
    jpg: "image/jpg",
    gif: "image/gif",
  }
end
