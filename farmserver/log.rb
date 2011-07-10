#
#
require 'thread'
#
class Log
	def initialize(out)
		@output = out
		@lock = Mutex.new
	end

	def write(msg)
		@lock.synchronize do
			@output.puts msg + "\r"
		end
	end
end

$Log = nil
