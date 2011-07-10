#!/usr/bin/ruby -w
#
require 'socket'

request = ""

begin
	client = TCPSocket.open("localhost", 8051)

	puts "Client started"
	puts "1: login"
	puts "2: state"
	puts "3: logout"
	puts "4: seed"
	puts "5: grow"
	puts "6: reap"
	puts "other: info"

	until client.closed?
		s = gets.chomp
		if s[0,1] == '$' then
			break
		else
			if s[0,1] == '1' then # login
				request = "<country><command id='login'><item user='x01' /></command></country>"
			elsif s[0,1] == '2' then # state
				request = "<country><command id='stat' /></country>"
			elsif s[0,1] == '3' then # logout
				request = "<country><command id='logout' /></country>"
			elsif s[0,1] == '4' then # seed
				request = "<country><command id='seed'><item posx='0' posy='1' type='clover' /></command></country>"
			elsif s[0,1] == '5' then # grow
				request = "<country><command id='grow' /></country>"
			elsif s[0,1] == '6' then # reap
				request = "<country><command id='reap'><item posx='0' posy='1' /></command></country>"
			else
				request = "<country><command id='info' /></country>"
			end
			client.send request, 0
			puts client.recv(20000)
		end
	end
rescue Exception => e
	p e
end
