#
#
require 'rexml/document'
require 'dbconn_mysql'
require 'log'
require 'svrcmd'
#

class SClient

	UNAUTHORIZED = 1
	READY = 2

	def initialize(socket, port)
		@state = UNAUTHORIZED
		@username = ""
		@request = ""
		@socket = socket
		@port = String(port)
		@@users = Array.new
		@@usersLock = Mutex.new
		@closed = false
	end

	def self.loggedin(username)
		@@usersLock.synchronize do
			return @@users.index(username) != nil
		end
	end

	def self.login(username)
		@@usersLock.synchronize do
			if @@users.index(username) == nil
				@@users << username
			end
		end
	end

	def self.logout(username)
		@@usersLock.synchronize do
			@@users.delete(username)
		end
	end

	def close
		@socket.shutdown
		@socket.close
	end

	def closed?
		return false
	end

	def run(dbconn)
		until @socket.closed?
			begin
				request = @socket.recv(20000, Socket::MSG_WAITALL);
				#$Log.write "request.length = " + String(request.length)
				@socket.send parse(request, dbconn).concat(0), 0
			rescue Errno::EPIPE
				break
			rescue IOError => e
				$Log.write "client: " + e.message + ", #{e.inspect}"
			rescue Exception => e
				$Log.write "client: exception " + e.message
			end
		end
		SClient.logout(@username)
		@closed = true
		#$Log.write "Client closed"
	end

	def parse(request, dbconn)

		#$Log.write request
		
		if request.length > 0 then

			if request.eql? "<policy-file-request/>\0" then
				#$Log.write "Security request"
				return "<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\""+@port+"\"/></cross-domain-policy>"
			end

			xml = REXML::Document.new(request)
			if xml.elements.count == 1 then
				elem = xml.elements[1]
				if elem.name == "country" then
					commands = elem.elements.to_a("command")
					if commands.count == 0 then
						return Error.xml($E_BADSYNTAX)
					end
					commands.each do |cmd|
						id = cmd.attributes["id"]
						if id == nil or id.length == 0 then
							return Error.xml($E_BADSYNTAX)
						end
						svrcmd = ServerCommand.new(id)
						items = cmd.elements.to_a("item")
						items.each do |item|
							cmditem = ServerCommandItem.new
							item.attributes.each_attribute do |attr|
								cmditem << [attr.expanded_name, attr.value]
							end
							svrcmd << cmditem
						end
						return processCommand(svrcmd, dbconn)
					end
				end
			end
		end
		return Error.xml($E_BADSYNTAX)
	end

	def processCommand(svrcmd, dbconn)
		
		case @state
		when UNAUTHORIZED
			begin
				if svrcmd.is "login" then
					return Error.xml($E_BADSYNTAX) if svrcmd.count == 0
					username,_ = svrcmd[0].params "user"
					return Error.xml($E_USEREXISTS) if SClient.loggedin(username) # already logged in
					return Error.xml($E_NOUSER) if dbconn.userexists(username) != 0 # not found in db
					@state = READY
					@username = username
					SClient.login(username)
					return Error.xml($E_OK)
				elsif svrcmd.is "new" then
 					return Error.xml($E_BADSYNTAX) if svrcmd.count == 0
					username,_ = svrcmd[0].params "user"
					return Error.xml($E_USEREXISTS) if SClient.loggedin(username) # already logged in
					return Error.xml($E_USEREXISTS) if dbconn.adduser(username) != 0 # user exists in db
					@state = READY
					@username = username
					SClient.login(username)
					return Error.xml($E_OK)
				end
			rescue ArgumentError
			end
			return Error.xml($E_UNAUTHORIZED)

		when READY
			begin
				if svrcmd.is "info" then
					return "<server info='#{dbconn.info}' />"
				elsif svrcmd.is "logout" then
					SClient.logout(@username)
					@state = UNAUTHORIZED
					@username = ""
					return Error.xml($E_OK)
				elsif svrcmd.is "kill" then
					dbconn.removeuser(@username)
					SClient.logout(@username)
					@state = UNAUTHORIZED
					@username = ""
					return Error.xml($E_OK)
				elsif svrcmd.is "stat" then # state
					return dbconn.gplay_stat(@username)
				elsif svrcmd.is "grow" then # grow all plants???
					return dbconn.gplay_grow(@username)
				elsif svrcmd.is "seed" then # seed a plant
					#x, y, plant = svrcmd.params "posx", "posy", "type"
					#return dbconn.gplay_seed(@username, x, y, plant)
					return dbconn.gplay_seed(@username, svrcmd)
				elsif svrcmd.is "reap" then # reap a plant
					#x, y = svrcmd.params "posx", "posy"
					return dbconn.gplay_reap(@username, svrcmd)
				end
			rescue ArgumentError
			end
			return Error.xml($E_BADSYNTAX)
		end # case @state
		return Error.xml($E_SERVERERROR) # ???

	rescue Exception => e
		$Log.write "#{e.class}: #{e}"
		return Error.xml($E_SERVERERROR)
	end
	
end

