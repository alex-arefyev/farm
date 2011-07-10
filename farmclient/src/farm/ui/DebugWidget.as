package farm.ui 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class DebugWidget extends Sprite 
	{
		private var text:TextField = new TextField();
		
		public function DebugWidget(w:int, h:int) 
		{
			graphics.beginFill(0x303030);
			graphics.drawRoundRect(0, 0, w, h, 20, 20);
			graphics.beginFill(0x7F7F7F);
			graphics.drawRoundRect(3, 3, w - 6, h - 6, 15, 15);
			graphics.endFill();
			
			text.x = 12;
			text.y = 12;
			text.width = super.width - 24;
			text.height = super.height - 24;
			addChild(text);
			
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.size = 12;
			tf.color = 0x000000;
			tf.leftMargin = 0;
			text.defaultTextFormat = tf;
		}
		
		public function add(s:String):void
		{
			text.text = s;
		}
	}

}