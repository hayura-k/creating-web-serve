require 'socket'
require 'uri'

# リクエストを捌いてレスポンスを作成するクラス
class WorkerThread
  attr_reader :socket
  # 静的配信するファイルを置くディレクトリ
  STATIC_ROOT = __dir__ + '/' + Dir.glob('static')[0]

  MIME_TYPES = {
    html: "text/html; charset=UTF-8",
    css: "text/css",
    png: "image/png",
    jpg: "image/jpg",
    gif: "image/gif",
  }

  def initialize(socket)
    @socket = socket
  end

  def run
    begin
      request = socket.recv(4096)
      method, path, http_version, request_header, request_body = parse_http_request(request)

      if path == '/now'
        response_body = <<~EOS
        <html>
        <body>
          <h1>Now: "#{Time.now}"</h1>
        </body>
        </html>
        EOS
        content_type = "text/html; charset=UTF-8"
        response_line = "HTTP/1.1 200 OK\r\n"
      elsif path == '/show_request'
        response_body = <<~EOS
        <html>
        <body>
          <h1>Request Line:</h1>
          <p>
              #{method} #{path} #{http_version}
          </p>
          <h1>Headers:</h1>
          <pre>#{request_header}</pre>
          <h1>Body:</h1>
          <pre>#{request_body}</pre>
        </body>
        </html>
        EOS
        content_type = "text/html; charset=UTF-8"
        response_line = "HTTP/1.1 200 OK\r\n"
      elsif path == '/parameters'
        if method == "GET"
          response_body = "<html><body><h1>405 Method Not Allowed</h1></body></html>"
          content_type = "text/html; charset=UTF-8"
          response_line = "HTTP/1.1 405 Method Not Allowed\r\n"
        elsif method == "POST"
          response_body = <<~EOS
          <html>
          <body>
            <h1>Parameters:</h1>
            <pre>#{URI.decode_www_form(request_body)}</pre>
          </body>
          </html>
          EOS
          content_type = "text/html; charset=UTF-8"
          response_line = "HTTP/1.1 200 OK\r\n"
        end
      else
        begin
          response_body = File.read(STATIC_ROOT + path)
          response_line = "HTTP/1.1 200 OK\r\n"
        rescue Errno::EISDIR
          response_body = "<html><body><h1>404 Not Found</h1></body></html>"
          response_line = "HTTP/1.1 404 Not Found\r\n"
        end
      end

      response_header = create_response_header(path, response_body, content_type)

      response = (response_line + response_header + "\r\n" + response_body).b

      puts '==レスポンスを送信します=='
      socket.send(response, 0)
    rescue => exception
      puts '==サーバーが終了しました=='
      puts exception
    ensure
      puts '==socketをcloseします=='
      socket.close
    end
  end

  private

  def parse_http_request(request)
    request_line, remain = request.split("\r\n", 2)
    request_header, request_body = remain.split("\r\n\r\n", 2)
    method, path, http_version = request_line.split(' ')
    [method, path, http_version, request_header, request_body]
  end

  def create_response_header(path, response_body, content_type)
    content_type = content_type || create_content_type(path)

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
