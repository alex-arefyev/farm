package farm.core 
{
	import flash.events.EventDispatcher;
	
	public final class Log extends EventDispatcher
	{
		private static var inst:Log = new Log();
		
		private function addMsg(s:String):void
		{
			dispatchEvent(new LogEvent(s));
		}
		
		public function Log() 
		{
			if (inst != null) throw "Log already instantianed";
		}
		
		public static function get instance():Log { return inst; }
		public static function write(s:String):void { inst.addMsg(s); }
		public static function subscribe(listener:Function):void { inst.addEventListener(LogEvent.MESSAGE, listener); }
		public static function unsubscribe(listener:Function):void { inst.removeEventListener(LogEvent.MESSAGE, listener); }
	}

}