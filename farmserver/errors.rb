#
#
$E_OK			= 0
$E_UNAUTHORIZED	= 1
$E_BADSYNTAX	= 2
$E_NOUSER  		= 3
$E_USEREXISTS	= 4
$E_DBERROR		= 500
$E_SERVERERROR	= 510
$E_FIELDEXISTS	= 520
$E_BADPARAM		= 521

# DB error
class Error
	def self.xml(errcode)
		msg = "unknown"
		case errcode
		when $E_OK 				then msg = "Ok"
		when $E_UNAUTHORIZED	then msg = "Unauthotized"
		when $E_BADSYNTAX		then msg = "Bad syntax"
		when $E_NOUSER 			then msg = "User not found"
		when $E_USEREXISTS		then msg = "User already exists"
		when $E_DBERROR 		then msg = "db error"
		when $E_SERVERERROR 	then msg = "server error"
		when $E_FIELDEXISTS 	then msg = "field already exists"
		when $E_BADPARAM 		then msg = "incorrect parameter"
		end
		return "<country><status error='#{errcode}' message='#{msg}' /></country>"
	end
end
