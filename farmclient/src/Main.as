package
{
	import farm.core.Image;
	import farm.ui.DebugWidget;
	import farm.ui.LoginWidget;
	import flash.display.Bitmap;
    import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.Keyboard;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
  
	import farm.core.GameManager;
	import farm.core.IGameManagerCallback;
	import farm.core.Resources;
	import farm.core.FarmField;
	import farm.core.Log;
	import farm.core.LogEvent;
	import farm.ui.Playground;
	import farm.ui.ImageButton;
	import farm.ui.ToolButton;
	import farm.ui.IPlaygroundOwner;
	import farm.ui.ILoginCallback;

	[Frame(factoryClass = "Preloader")]
	[SWF(backgroundColor="0xD1EFC4")]
	public class Main extends Sprite implements IPlaygroundOwner, ILoginCallback, IGameManagerCallback
	{
		private const StateConnect:int = 0;
		private const StateLogin:int = 1;
		private const StatePlay:int = 2;
		private var state:int = -1;
		
		private var gameManager:GameManager = null;
		private var playground:Playground = null;
		
		private var btnToolClover:ToolButton = null;
		private var btnToolPotato:ToolButton = null;
		private var btnToolSunflower:ToolButton = null;
		private var btnToolWatering:ImageButton = null;
		private var btnToolBasket:ImageButton = null;
		private var btnExit:ImageButton = null;
		private var toolEnabled:Boolean = false;
		private var toolWidget:Sprite = null;
		private var selectionWidget:Sprite = null;
		private var debugWindow:DebugWidget = null;
		private var loginWindow:LoginWidget = null;
		
		private var cursor:Sprite = null;
		
		private var pgWidth:int = 0;
		private var pgHeight:int = 0;
		private var mouseDown:Boolean = false;
		private var startPos:Point = new Point();
		
		//test
		private var testImg:Image = new Image();
		private function testImageLoaded(img:Bitmap):void
		{
			testImg.getImage(testImageLoaded2, "bg");
		}
		private function testImageLoaded2(img:Bitmap):void
		{
			
		}
		
		// helpers
		private function createToolCursor(img:Bitmap):Boolean
		{
			cancelToolCursor();
			
			if (img != null) {
				cursor = new Sprite();
				cursor.graphics.beginBitmapFill(img.bitmapData); 
				cursor.graphics.endFill();
				cursor.addChild(img);
				addChild(cursor); 
				 
				stage.addEventListener(MouseEvent.MOUSE_MOVE, redrawToolCursor); 
				cursor.x = stage.mouseX + 3; 
				cursor.y = stage.mouseY + 3;
				
				return true;
			}
			return false;
		}
		private function cancelToolCursor():void
		{
			if (cursor != null) {
				removeChild(cursor);
				cursor = null;
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, redrawToolCursor); 
			}
		}
		private function redrawToolCursor(event:MouseEvent):void 
		{ 
			cursor.x = event.stageX + 3; 
			cursor.y = event.stageY + 3; 
		}
		private function showToolControls(show:Boolean = true):void
		{
			btnToolClover.visible = show;
			btnToolPotato.visible = show;
			btnToolSunflower.visible = show;
			btnToolBasket.visible = show;
			btnToolWatering.visible = show;
			btnExit.visible = show;
			playground.visible = show;
		}
		private function showLoginWidget(show:Boolean = true):void
		{
			if (show) {
				loginWindow = new LoginWidget(this);
				loginWindow.x = (stage.stageWidth - loginWindow.width) / 2;
				loginWindow.y = 200;
				addChild(loginWindow);
			} else {
				if (loginWindow != null) {
					removeChild(loginWindow);
					loginWindow = null;
				}
			}
		}
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function parseStatus(node:XMLNode):void
		{
			var error:String = "";// node.attributes.error;
			var err:int = int(error);
			trace (err.toString());
		}
		private function xmlTest():void
		{
			var xml:XML = new XML("<country>\n\t<status error='0' message='Ok' />\n</country>");
			debugWindow.add(xml);
			
			var xDoc:XMLDocument = new XMLDocument();
			xDoc.ignoreWhite = true;
			xDoc.parseXML(xml.toXMLString());
			
			//xDoc.
			if (xDoc.childNodes.length == 1 && xDoc.firstChild.nodeName == "country") {
				var node:XMLNode = xDoc.firstChild;
				for each (var i:XMLNode in node.childNodes) {
					trace(i.nodeName);
					if (i.nodeName == "status") {
						parseStatus(i);
					}
				}
			}
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			Resources.Initialize();
			
			// entry point
			/*
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			*/
			
			debugWindow = new DebugWidget(300, 150);
			debugWindow.x = 130;
			debugWindow.y = 10;
			addChild(debugWindow);
			debugWindow.visible = false;
			Log.subscribe(onLogMessage);
			
			var keyStr:String = "", valueStr:String = "";
			var flashVars:Object = this.loaderInfo.parameters;
			var s:String = "";
			for (keyStr in flashVars) {
				valueStr = String(flashVars[keyStr]);
				s += "\t" + keyStr + ":\t" + valueStr + "\n";
			}
			Log.write(s);
			//return;
			
			var addr:String = flashVars["addr"];
			if (addr == null) {
				addr = "localhost:8051";
			}
			//testImg.getImage(testImageLoaded, "bg", true);
			
			//Log.write("Starting...");
			//playground = new Playground(this, Resources.image("bg"), 117, 432, 744, 107, 97, 51, 0);
			//addChildAt(playground, 0);
			//return;
			
			gameManager = new GameManager(this);
			gameManager.addEventListener(GameManager.CONNECT, onConnect);
			gameManager.addEventListener(GameManager.RECONNECT, onReconnect);
			gameManager.addEventListener(GameManager.DISCONNECT, onDisconnect);
			
			state = StateConnect;
			gameManager.connect(addr);
		}
		
		private function createGame():void
		{
			showLoginWidget(false);
			
			if (playground == null) {
				removeChild(debugWindow);

				playground = new Playground(this, Resources.image("bg"), 117, 432, 744, 107, 97, 51, 0);
				addChildAt(playground, 0);
				pgWidth = 1565;// playground.width;
				pgHeight = 908;// playground.height;

				//var imgC:Bitmap = Resources.image("clover/4");
				//var imgP:Bitmap = Resources.image("potato/4");
				//var imgS:Bitmap = Resources.image("sunflower/4");
				
				var btnWidth:int = 110;// Math.max(imgC.width, Math.max(imgP.width, imgS.width)) + 10;
				var btnHeight:int = 110;// Math.max(imgC.height, Math.max(imgP.height, imgS.height)) + 10;
				
				var btny:int = 10;
				var dy:int = 5;
				btnToolClover = new ToolButton("clover/4", btnWidth, btnHeight);
				addChild(btnToolClover);
				btnToolClover.addEventListener(MouseEvent.CLICK, onToolCloverClick);
				btnToolClover.x = 10;
				btnToolClover.y = btny;
				btny += btnHeight + dy;
				
				btnToolPotato = new ToolButton("potato/4", btnWidth, btnHeight);
				addChild(btnToolPotato);
				btnToolPotato.addEventListener(MouseEvent.CLICK, onToolPotatoClick);
				btnToolPotato.x = 10;
				btnToolPotato.y = btny;
				btny += btnHeight + dy;
				
				btnToolSunflower = new ToolButton("sunflower/4", btnWidth, btnHeight);
				addChild(btnToolSunflower);
				btnToolSunflower.addEventListener(MouseEvent.CLICK, onToolSunflowerClick);
				btnToolSunflower.x = 10;
				btnToolSunflower.y = btny;
				btny += btnHeight + dy + 30;
				
				btnToolWatering = new ImageButton(Resources.image("tools/watering"), true);
				addChild(btnToolWatering);
				btnToolWatering.addEventListener(MouseEvent.CLICK, onToolWateringClick);
				btnToolWatering.x = 10;
				btnToolWatering.y = btny;
				btny += btnToolWatering.height + 5;
				
				btnToolBasket = new ImageButton(Resources.image("tools/cut"), true);
				addChild(btnToolBasket);
				btnToolBasket.addEventListener(MouseEvent.CLICK, onToolShovelClick);
				btnToolBasket.x = 10;
				btnToolBasket.y = btny;
				btny += btnToolBasket.height + 5;
				
				btnExit = new ImageButton(Resources.image("door"), true);
				addChild(btnExit);
				btnExit.addEventListener(MouseEvent.CLICK, onToolExitClick);
				btnExit.x = 10;
				btnExit.y = btny;
				btny += btnExit.height + 5;
				
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				
				addChild(debugWindow);
				debugWindow.visible = false;
			} else {
				showToolControls();
			}
			
			//var btn:ImageButton = null;
			/*	
			btnToolNone = new ImageButton(Resources.image("tools/none"));
			addChild(btnToolNone);
			btnToolNone.addEventListener(MouseEvent.CLICK, onToolNoneClick);
			btnh = btnToolNone.height;
			btnToolNone.x = 10;
			btnToolNone.y = btny;
			btny += btnh + 5;*/
			
			playground.sync(gameManager.farmfield);
		}
		
		private function onConnect(e:Event):void
		{
			state = StateLogin;
			
			showLoginWidget();
			
			Log.write("Connected");
		}

		private function onReconnect(e:Event):void
		{
			
		}

		private function onDisconnect(e:Event):void
		{
			
		}

		private function onBeginTransaction(e:Event):void
		{
			
		}

		private function onEndTransaction(e:Event):void
		{
			
		}
		
		// tool events
		private function onToolCloverClick(e:MouseEvent):void
		{
			if (gameManager.seed("clover")) {
				playground.sync(gameManager.farmfield);
			}
		}
		private function onToolPotatoClick(e:MouseEvent):void
		{
			if (gameManager.seed("potato")) {
				playground.sync(gameManager.farmfield);
			}
		}
		private function onToolSunflowerClick(e:MouseEvent):void
		{
			if (gameManager.seed("sunflower")) {
				playground.sync(gameManager.farmfield);
			}
		}
		private function onToolWateringClick(e:MouseEvent):void
		{
			gameManager.grow();
			playground.sync(gameManager.farmfield);
		}
		private function onToolShovelClick(e:MouseEvent):void
		{
			//gameManager.clear();
			//playground.sync(gameManager.farmfield);
			if (toolWidget == btnToolBasket) {
				toolEnabled = false;
				toolWidget = null;
				cancelToolCursor();
			} else {
				if (createToolCursor(Resources.image("tools/cursorCut"))) {
					toolWidget = btnToolBasket;
					toolEnabled = true;
				}
			}
		}
		private function onToolExitClick(e:MouseEvent):void
		{
			gameManager.logout();
		}
		
		// keyboard events
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch (e.keyCode) {
				case Keyboard.ESCAPE:
				if (toolEnabled) {
					toolEnabled = false;
					cancelToolCursor();
				}
				break;
			}
		}

		// mouse events
		private function onMouseDown(e:MouseEvent):void
		{
			if (toolEnabled) {
				mouseDown = true;
				startPos.x = e.localX;
				startPos.y = e.localY;
				selectionWidget = new Sprite();
				stage.addChild(selectionWidget);
				selectionWidget.x = e.stageX;
				selectionWidget.y = e.stageY;
				//stage.addEventListener(MouseEvent.MOUSE_MOVE, onSelectionMove);
				//stage.addEventListener(MouseEvent.MOUSE_UP, onSelectionUp);
			} else {
				mouseDown = true;
				startPos.x = e.localX;
				startPos.y = e.localY;
			}
		}
		private function onMouseUp(e:MouseEvent):void
		{
			mouseDown = false;
			if (selectionWidget != null) {
				stage.removeChild(selectionWidget);
				selectionWidget = null;
			}
		}
		private function onMouseOver(e:MouseEvent):void
		{
			if (toolEnabled) {
				if (cursor != null) { cursor.visible = true; }
			}
		}
		private function onMouseOut(e:MouseEvent):void
		{
			if (toolEnabled) {
				if (cursor != null) { cursor.visible = false; }
			} else {
				//mouseDown = false;
			}
		}
		private function onMouseMove(e:MouseEvent):void
		{
			if (mouseDown) {
				if (!toolEnabled) {
					var dx:int = e.localX - startPos.x;
					var dy:int = e.localY - startPos.y;
					
					var x:int = playground.x + dx;
					if (x > 0) { x = 0; }
					else if (x < stage.stageWidth - playground.imageWidth()) { x = stage.stageWidth - playground.imageWidth(); }
					playground.x = x;

					var y:int = playground.y + dy;
					if (y > 0) { y = 0; }
					else if (y < stage.stageHeight - playground.imageHeight()) { y = stage.stageHeight - playground.imageHeight(); }
					playground.y = y;
				}
			}
		}
		
		// log event
		private function onLogMessage(e:LogEvent):void
		{
			debugWindow.add(e.message);
		}
		
		// ILoginCallback
		public function onLoginEnter(s:String):void
		{
			if (s.length > 0) {
				gameManager.login(s);
			}
			//createGame();
		}
		public function onAddUser(s:String):void
		{
			if (s.length > 0) {
				gameManager.addUser(s);
			}
		}
		public function onDeleteUser(s:String):void
		{
			
		}

		
		// IPlantingOwner ???
		public function plantingClicked(posx:int, posy:int):void
		{
			var res:Boolean = false;
			
			if (toolWidget == btnToolBasket) {
				res = gameManager.reap(posx, posy);
			} else {
				res = gameManager.select(posx, posy);
			}
			
			/* old
			if (toolWidget == null) {
				// nothing to do
				return;
			}
			var res:Boolean = false;
			if (toolWidget == btnToolClover) {
				res = gameManager.seed("clover", posx, posy);
			} else if (toolWidget == btnToolPotato) {
				res = gameManager.seed("potato", posx, posy);
			} else if (toolWidget == btnToolSunflower) {
				res = gameManager.seed("sunflower", posx, posy);
			} else { // reap
				gameManager.reap(posx, posy);
				res = true;
			}
			*/
			if (res) {
				playground.sync(gameManager.farmfield);
			}
		}
		public function plantingSelectionStarted(posx:int, posy:int):void
		{
			var b:Boolean = gameManager.deselect();
			//b = gameManager.select(posx, posy) || b;
			if (b) {
				playground.sync(gameManager.farmfield);
			}
		}
		public function plantingSelectionUpdated(sx:int, sy:int, ex:int, ey:int):void
		{
			if (gameManager.multiselect(sx, sy, ex, ey)) {
				playground.sync(gameManager.farmfield);
			}
		}
		
		// IGameManagerCallback
		public function connectToServer():void
		{
			
		}
		
		public function reconnectToServer():void
		{
			
		}
		
		public function errorIoServer(s:String):void
		{
			switch (state) {
				case StateConnect:
					debugWindow.add("Unable to connect to the server");
					break;
				case StateLogin:
					break;
					
				case StatePlay:
					debugWindow.add("Server IO error: "+s);
					break;
			}
		}
		
		public function beginServerTransaction():void
		{
			
		}
		public function endServerTransaction():void
		{
			
		}
		
		public function statusReceived(val:int, msg:String):void
		{
		}
		
		public function loggedIn():void
		{
			Log.write("loggedIn()");
			switch (state) {
				case StateLogin:
			Log.write("logged in");
					state = StatePlay;
					createGame();
					gameManager.stat();
				break;
			}
		}
		public function loginFailed(val:int, msg:String):void
		{
			debugWindow.add(msg);
		}
		public function loggedOut():void
		{
			showToolControls(false);
			
			Log.write("logged out");
			
			showLoginWidget();
			state = StateLogin;
		}
		public function logoutFailed(val:int, msg:String):void
		{
			debugWindow.add(msg);
		}
		public function farmFieldChanged():void
		{
			playground.sync(gameManager.farmfield);
		}
		
		
		
		public function requestReady(s:String):void
		{
			//debugWindow.add(s);
		}
		
		public function responseReceived(s:String):void
		{
			//debugWindow.add(s);
		}
		
		public function debugString(s:String):void
		{
			if (s != null) {
				debugWindow.add(s);
			} else {
				debugWindow.add("debug string ???");
			}
		}

/*		public function deselect():void
		{
			if (gameManager.deselect()) {
				playground.sync(gameManager.farmfield);
			}
		}
		public function plantingStartDrag(posx:int, posy:int):void
		{}*/
	}
}

