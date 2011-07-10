package farm.core 
{
	import flash.net.XMLSocket;

	public final class Protocol 
	{
		private var xml:String = "";
		
		public function Protocol() 
		{
		}
	
		public function beginRequest():void
		{
			xml = "<country>";
		}
		public function endRequest():void
		{
			xml += "</country>";
		}
		public function addCommand(cmd:String):void
		{
			xml += "<command id='" + cmd + "'" + " />";// + "\n";
		}
		public function beginCommand(cmd:String):void
		{
			var s:String = "<command id='" + cmd + "'" + ">";// + "\n";
			xml += s;
		}
		public function endCommand():void
		{
			xml += "</command>";// + "\n";
		}
		public function addCommandItem(params:Array):void
		{
			if (params == null || params.length == 0) {
				return;
			}
			var s:String = "<item ";
			for each (var pair:Array in params) {
				s += pair[0] + "='" + pair[1] + "' ";
			}
			s += "/>";// + "\n";
			xml += s;
		}
		
		public function get request():String { return xml; }
	}

}