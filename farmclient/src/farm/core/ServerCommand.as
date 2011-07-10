package farm.core 
{
	import flash.net.XMLSocket;
	
	public class ServerCommand 
	{
		public static const Login:int  = 0;
		public static const Logout:int = 1;
		public static const State:int  = 2;
		public static const Seed:int   = 3;
		public static const Reap:int   = 4;
		public static const Grow:int   = 5;
		
		protected var cmdString = "";
		protected var params = null;
		
		public function ServerCommand(cmd:String, prms:Array) 
		{
			cmdString = cmd;
			params = prms;
		}
		
		public static function send(cmd:ServerCommand, socket:XMLSocket):Boolean
		{
			if (cmd == null || cmd.cmdString.empty() || cmd.params.length == 0) {
				return false;
			}
			var xml:String = buildXmlCommand(cmd.cmdString, cmd.params);
			socket.send(new XML(xml));
			return true;
		}
		
		public static function buildXmlCommand(cmd:String, params:Array):String
		{
			var xml:String = new String("<country><command id='"+cmd+"'");
			if (params == null || params.length == 0) {
				xml += " /></country>";
			} else {
				xml += ">";
				for (var idx:int; idx < params.length; ++idx) {
					var param:Array = params[idx];
					xml += "<param name='" + param[0] + "' value='" + param[1] + "' />";
				}
				xml += "</command></country>";
			}
			return xml;
		}
		
	}

}