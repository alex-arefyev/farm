#
#
class ServerCommandItem < Array

	def params(*ap)
		return raise ArgumentError if count != ap.count
		ret = Array.new
		ap.each do |param|
			pair = assoc(param)
			raise ArgumentError if pair == nil or pair.count != 2
			ret << pair[1]
		end
		return ret
	end

end

class ServerCommand < Array

	def initialize(cmdId)
		@id = cmdId
	end

	def is(id)
		return (@id <=> id) == 0 ? true : false
	end

end

