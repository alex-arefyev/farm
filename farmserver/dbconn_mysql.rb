#
#
#
require 'thread'
require 'mysql'
require 'errors'
require 'log'
require 'svrcmd'

$field_width = 13
$field_height = 13
$max_growth = 5

# DB connection
class DBConnection# < DBAdapter

	def initialize()
		@dbh = nil
		@lock = Mutex.new
	end
	
	def init(hostname, user, pwd)
	    # connect to the MySQL server
	    @dbh = Mysql.real_connect(hostname, user, pwd, "farmgame")
		@basetime = Time.utc(2010).to_i
	    # get server version string and display it
		#res = @dbh.query("SELECT name FROM users")
		#while row = res.fetch_row do
		#	printf "%s, %s\n", row[0], row[1]
		#end
		#$Log.write "Number of rows returned: #{res.num_rows}"
		return 1
	  rescue Mysql::Error => e
	    $Log.write "Error code: #{e.errno}"
	    $Log.write "Error message: #{e.error}"
	    $Log.write "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
	  ensure
	end
	
	def close()
	    # disconnect from server
	    @dbh.close if @dbh
	end
	
	def info()
		return @dbh.get_server_info if @dbh
		return "error: not connected"
	end
	
	# user mgmt
	# all functions return error code
	def adduser(username)
		@lock.synchronize do
			if @dbh then
				query = "SELECT name FROM users WHERE name='" + username + "'"
				res = @dbh.query(query)
				if res.num_rows > 0 then
					#$Log.write "error: user exists"
					return 1
				end
				query = "INSERT INTO users (name) VALUES ('"+username+"')"
				res = @dbh.query(query)
				if @dbh.affected_rows == 1 then
					query = "SELECT id, name FROM users WHERE name='"+username+"'"
					res = @dbh.query(query)
					if res.num_rows == 1 then
						user = res.fetch_row()
						dbname = "userfield_" + user[0]
						query = "CREATE TABLE IF NOT EXISTS "+dbname+" ( idx INT, plant CHAR(16), growth INT, updated INT )"
						res = @dbh.query(query)
					end
					return 0
				end
				$Log.write "user not added"
				return 100
			end
		end
	rescue Mysql::Error => e
		$Log.write "#{e.class}: #{e}"
		return -1
	rescue Exception => e
		$Log.write "#{e.class}: #{e}"
		return -1
	end
	
	def removeuser(username)
		@lock.synchronize do
			if @dbh then
				query = "SELECT id, name FROM users WHERE name='"+username+"'"
				res = @dbh.query(query)
				if res.num_rows == 1 then
					user = res.fetch_row()
					$Log.write "user to remove: #{user[1]}"
					query = "DELETE FROM users WHERE name='"+username+"'"
					res = @dbh.query(query)
					dbname = "userfield_" + user[0]
					query = "DROP TABLE IF EXISTS "+dbname
					@dbh.query(query)
					return 0
				end
				return -1
			end
		end
	rescue Mysql::Error => e
		$Log.write "#{e.class}: #{e}"
		return -1
	rescue Exception => e
		$Log.write "#{e.class}: #{e}"
		return -1
	end
	
	def userexists(username)
		@lock.synchronize do
			if @dbh then
				query = "SELECT id FROM users WHERE name='"+username+"'"
				res = @dbh.query(query)
				if res.num_rows == 1 then
					return 0
				end
				return 1
			end
			return -1
		end
	rescue Mysql::Error => e
		$Log.write "#{e.class}: #{e}"
		return -1
	rescue Exception => e
		$Log.write "#{e.class}: #{e}"
		return -1
	end
	
	def testuser(username)
		@lock.synchronize do
			if @dbh then
				query = "SELECT id,name FROM users WHERE name='"+username+"'"
				res = @dbh.query(query)
				while row = res.fetch_row do
					printf "%s, %s\n", res[0], row[1]
				end
			end
		end
	rescue Mysql::Error => e
		$Log.write "#{e.class}: #{e}"
		return -1
	rescue Exception => e
		$Log.write "#{e.class}: #{e}"
		return -1
	end
	
	def listusers()
		@lock.synchronize do
			if @dbh then
				query = "SELECT id,name FROM users"
				res = @dbh.query(query)
				while row = res.fetch_row do
					printf "%s, %s\n", row[0], row[1]
				end
			end
		end
	rescue Mysql::Error => e
		$Log.write "#{e.class}: #{e}"
		return -1
	rescue Exception => e
		$Log.write "#{e.class}: #{e}"
		return -1
	end
	
	# helper functions
	def user_db_stat(dbname)
		query = "SELECT idx,plant,growth,updated FROM "+dbname
		res = @dbh.query(query)
		xml = "<country>\n\t<field sizex='#{$field_width}' sizey='#{$field_height}'>\n"
		while row = res.fetch_row do
			idx = Integer(row[0])
			x = idx / $field_width
			y = idx % $field_width
			xml += "\t\t<planting posx='#{String(x)}' posy='#{String(y)}' type='#{row[1]}' growth='#{row[2]}' updated='#{row[3]}' />\n"
		end
		xml += "\t</field>\n</country>"
		return xml
	end
	
	# gameplay functions
	# each function returns xml
	def gplay_stat(username)
		@lock.synchronize do
			if @dbh then
				query = "SELECT id FROM users WHERE name='"+username+"'"
				res = @dbh.query(query)
				if res.num_rows == 1 then
					user = res.fetch_row
					dbname = "userfield_" + user[0]
					return user_db_stat(dbname)
				end
				return Error.xml($E_NOUSER)
			end
		end
	rescue Mysql::Error => e
		$Log.write "#{e.class}: #{e}"
		return Error.xml($E_DBERROR)
	rescue Exception => e
		$Log.write "#{e.class}: #{e}"
		return Error.xml($E_SERVERERROR)
	end
	
	def gplay_seed(username, items)
		@lock.synchronize do
			if @dbh then
				query = "SELECT id,name FROM users WHERE name='"+username+"'"
				res = @dbh.query(query)
				if res.num_rows == 1 then
					user = res.fetch_row
					dbname = "userfield_" + user[0]
					begin
						items.each do |item|
							sx, sy, plant = item.params "posx", "posy", "type"
							x = Integer(sx)
							y = Integer(sy)
							if x < $field_width and y < $field_height then
								idx = String(x*$field_width+y)
								query = "SELECT idx FROM "+dbname+" WHERE idx='"+idx+"'"
								res = @dbh.query(query)
								if res.num_rows == 0 then
									updated = String(Time.now.utc.to_i - @basetime)
									query = "INSERT INTO "+dbname+" (idx,plant,growth,updated) VALUES ("+idx+",'"+plant+"',1,"+updated+")"
									#$Log.write query
									@dbh.query(query)
								else
									return Error.xml($E_FIELDEXISTS)
								end
							end
						end
						return user_db_stat(dbname)
					rescue  ArgumentError
						return Error.xml($E_BADSYNTAX)
					end
				end
				return Error.xml($E_NOUSER)
			end
		end
	rescue Mysql::Error => e
		$Log.write "#{e.class}: #{e}"
		return Error.xml($E_DBERROR)
	rescue Exception => e
		$Log.write "#{e.class}: #{e}"
		return Error.xml($E_SERVERERROR)
	end

	def gplay_grow(username)
		@lock.synchronize do
			if @dbh then
				query = "SELECT id FROM users WHERE name='"+username+"'"
				res = @dbh.query(query)
				if res.num_rows == 1 then
					user = res.fetch_row
					dbname = "userfield_" + user[0]
					query = "SELECT idx,growth FROM "+dbname
					res = @dbh.query(query)
					while row = res.fetch_row do
						idx = row[0]
						newState = Integer(row[1]) + 1
						#$Log.write "#{idx}, #{newState}"
						if newState <= $max_growth then
							updated = String(Time.now.utc.to_i - @basetime)
							query = "UPDATE "+dbname+" SET growth='"+String(newState)+"',updated='"+updated+"' WHERE idx='"+idx+"'"
							#$Log.write query
							@dbh.query(query)
						end
					end
					return user_db_stat(dbname)
				end
				return Error.xml($E_NOUSER)
			end
		end
	rescue Mysql::Error => e
		$Log.write "#{e.class}: #{e}"
		return Error.xml($E_DBERROR)
	rescue Exception => e
		$Log.write "#{e.class}: #{e}"
		return Error.xml($E_SERVERERROR)
	end

	def gplay_reap(username, items)
		@lock.synchronize do
			if @dbh then
				query = "SELECT id FROM users WHERE name='"+username+"'"
				res = @dbh.query(query)
				if res.num_rows == 1 then
					user = res.fetch_row
					dbname = "userfield_" + user[0]
					begin
						items.each do |item|
							sx, sy = item.params "posx", "posy"
							x = Integer(sx)
							y = Integer(sy)
							if x < $field_width and y < $field_height then
								idx = String(x*$field_width+y)
								#$Log.write idx
								query = "DELETE FROM "+dbname+" WHERE idx='"+idx+"'"
								res = @dbh.query(query)
							end
						end
						return user_db_stat(dbname)
					rescue ArgumentError
						return Error.xml($E_BADPARAM)
					end					
				end
				return Error.xml($E_NOUSER)
			end
			return Error.xml($E_SERVERERROR)
		end
	rescue Mysql::Error => e
		$Log.write "#{e.class}: #{e}"
		return Error.xml($E_DBERROR)
	rescue ArgumentError
		return Error.xml($E_BADSYNTAX)
	rescue Exception => e
		$Log.write "#{e.class}: #{e}"
		return Error.xml($E_SERVERERROR)
	end
end
