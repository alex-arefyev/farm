#!/usr/bin/ruby -w
#
require 'socket'
require 'dbconn_mysql'
require 'gamesclient'
require 'log'

class Server
	
	def initialize
		@runn = false
		@clients = Array.new
	end
	
	def running
		return @runn
	end

	def adduser(username)
		return 0;
	end

	def removeuser(username)
		return 0;
	end
	
	def run(server, dbconn)
		@runn = true
		$Log.write "Server started"
		loop do
			socket = server.accept
			#$Log.write "Client accepted"
			@clients.delete_if { |c| c.closed? }
			Thread.new { client = SClient.new(socket,$port); @clients << client; client.run(dbconn) }
		end
	rescue Exception => e
		$Log.write "server: " + e.message
	ensure
		@runn = false
		@clients.each do |c|
			$Log.write "close client"
			c.close
		end
	end
end

# start
unless ARGV.length == 1
  puts "Usage: ruby gameserver.rb <port>\n"
  exit
end

$port = 8051
begin
  $port = Integer(ARGV[0])
rescue
  puts "Usage: ruby gameserver.rb <port>\n"
  exit
end

system("stty raw -echo") #=> Raw mode, no echo

$Log = Log.new(STDOUT)

begin
dbconn = DBConnection.new
if dbconn then
	$Log.write "Connect to DB..."
	dbconn.init("localhost", "farmgamer", "mysql")
	$Log.write "OK"

	$Log.write "Start server on #{$port}..."
	server = TCPServer.open($port)
	server.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)

	serverThread = Thread.new { Server.new.run(server, dbconn) }

	$Log.write "Hit 'q' to stop server"
	loop do
		begin
			break if STDIN.read_nonblock(1) == 'q'
			rescue Errno::EWOULDBLOCK, Errno::EAGAIN, Errno::EINTR
		end
		sleep 1
	end

	server.close
	
end
rescue Exception => e
	$Log.write e.message
ensure
	system("stty -raw echo") #=> Reset terminal mode
end
