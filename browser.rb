require 'socket'
require 'json'

host = 'localhost'
port = 2000
path = "/thanks.html"

puts 'Which type of request do you want to send?'
input = gets.chomp.downcase

if input == 'get'
  request = "GET #{path} HTTP/1.0\r\n\r\n"
elsif input == 'post'
  information = Hash.new
  puts 'What is the name of the viking?'
  information[:name] = gets.chomp
  puts 'What is the email of the viking?'
  information[:email] = gets.chomp
  viking = {
    :viking => information
  }
  json_viking = viking.to_json

  request = "POST #{path} HTTP/1.1\r\n" +
             "Content-Length: #{json_viking.bytesize}\r\n" +
             "\r\n\r\n" +
             json_viking
end

socket = TCPSocket.open(host, port)  # Connect to server
socket.print(request)               # Send request
response = socket.read              # Read complete response
# Split response at first blank line into headers and body
headers, body = response.split("\r\n\r\n", 2)
headers = headers.split("\r\n")

if /200/.match(headers[0])
  print body
elsif /404/.match(headers[0])
  print "404! 404! 404!\r\n"
else
end

