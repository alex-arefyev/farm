package farm.core 
{
	import flash.events.Event;
	
	public final class LogEvent extends Event
	{
		public static const MESSAGE:String = "message_added";
		
		private var msg:String = "";
	
		public function LogEvent(s:String) 
		{
			super(MESSAGE);
			msg = s;
		}
		
		public function get message():String { return msg; }
	}

}