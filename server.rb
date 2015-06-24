require 'socket'
require 'json'

content_type_mapping = {
  'html' => 'text/html',
  'txt' => 'text/plain',
  'png' => 'image/png',
  'jpg' => 'image/jpeg'
}

server = TCPServer.open(2000)
loop do
  socket = server.accept
  request = begin
              socket.read_nonblock(256)
            rescue Errno::EAGAIN
              retry
            end

  headers, body = request.split("\r\n\r\n")

  method = headers.split[0]
  path = headers.split[1]
  path[0] = ''
  extension = path.split('.')[1]


  if File.exist?(path)
    file = File.read(path)
    socket.print "HTTP/1.1 200 OK\r\n" +
                 "Content-Type: #{content_type_mapping[extension]}\r\n" +
                 "Content-Size: #{file.bytesize}\r\n"

    socket.print "\r\n"

    if method == 'GET'
      socket.print file
    elsif method == 'POST'
      params = JSON.parse(body)
      file.gsub!('<%= yield %>', "<li>Name: #{params['viking']['name']}</li><li>Email: #{params['viking']['email']}</li>")
      socket.print file
    end

  else
    socket.print "HTTP/1.1 404 Not Found\r\n"
  end

  socket.close
end