package farm.ui 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	//import flash.events.TextEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	
	import farm.core.Resources;
	import farm.ui.ImageButton;
	import farm.ui.ILoginCallback;
	
	public final class LoginWidget extends Sprite 
	{
		private var input:TextField = null;
		
		public function LoginWidget(cb:ILoginCallback) 
		{
			var w:int = 300, h:int = 110;
			
			graphics.beginFill(0x303030);
			graphics.drawRoundRect(0, 0, w, h, 20, 20);
			graphics.beginFill(0xCFCFCF);
			graphics.drawRoundRect(3, 3, w - 6, h - 6, 15, 15);
			graphics.endFill();
			
			input = new TextField();
			input.type = TextFieldType.INPUT;
			input.border = true;
			input.multiline = false;
			input.wordWrap = false;
			input.x = 16;
			input.y = 12;
			input.width = super.width - 32;
			input.height = 32;
			input.background = true;
			addChild(input);
			
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.size = 20;
			tf.bold = true;
			tf.color = 0x0000FF;
			tf.leftMargin = 3;
			input.defaultTextFormat = tf;
			input.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void { if (cb != null && e.keyCode == Keyboard.ENTER) cb.onLoginEnter(input.text) })
			
			var btn:ImageButton = new ImageButton(Resources.image("check"));
			addChild(btn);
			btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { if (cb != null) cb.onLoginEnter(input.text) } );
			btn.x = w - btn.width - 10;
			btn.y = 50;
			
			btn = new ImageButton(Resources.image("add"));
			addChild(btn);
			btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { if (cb != null) cb.onAddUser(input.text) } );
			btn.x = 10;
			btn.y = 50;
/*			
			btn = new ImageButton(Resources.image("delete"));
			addChild(btn);
			btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { if (cb != null) cb.onDeleteUser(input.text) } );
			btn.x = 10 + 10 + btn.width;
			btn.y = 50;
*/
			
			if (stage != null) initialize();
			else addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		
		private function initialize(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			stage.focus = input;
		}
	
		public function get value():String { return input.text; }
	}

}