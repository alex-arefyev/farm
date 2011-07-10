package farm.core 
{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.net.XMLSocket;
	import flash.events.DataEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.Security;
	import flash.errors.IOError;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import farm.core.IGameManagerCallback;
	import farm.core.Protocol;
	import farm.core.Log;
	
	public final class GameManager extends EventDispatcher
	{
		public static const CONNECT : String = "onConnect";
		public static const RECONNECT : String = "onReconnect";
		public static const DISCONNECT : String = "onDisconnect";
		public static const ERROR : String = "onError";
		public static const BEGINTRANSACT : String = "onBeginTransaction";
		public static const ENDTRANSACT : String = "onEndTransaction";
		public static const FIELDCHANGED : String = "onFieldChanged";
		
		private const StateLogin:int = 0;
		private const StateLogout:int = 1;
		private const StateAddUser:int = 2;
		private const StateDeleteUser:int = 3;
		private const StatePlay:int = 4;
		
		private var state:int = -1;
		private var loginStr:String = "";
		
		private var xDoc:XMLDocument = new XMLDocument();
		
		
		private var callback:IGameManagerCallback = null;
		
		private var protocol:Protocol = new Protocol();
		private var waitResponse:Boolean = false;
		
		private var server:XMLSocket = new XMLSocket();
		private var field:FarmField = null;
		private const dimx:int = 13;
		private const dimy:int = 13;
		
		private function parseStatusNode(node:XMLNode):void
		{
			var error:String = node.attributes.error;
			var err:int = int(error);
			trace (err.toString());

			switch (state) {
				case StateLogin:
				{
					if (err == 0) {
						state = StatePlay;
						callback.loggedIn();
						
						sendStatCmd();
					} else {
						callback.loginFailed(err, node.attributes.message);
					}
				}
				break;
				
				case StateLogout:
				{
					if (err == 0) {
						state = -1;
						callback.loggedOut();
						clear();
						callback.farmFieldChanged();
					} else {
						callback.logoutFailed(err, node.attributes.message);
					}
				}
				break;
				
				case StateAddUser:
				{
					if (err == 0) {
						state = StatePlay;
						callback.loggedIn();
						
						sendStatCmd();
					} else {
						callback.loginFailed(err, node.attributes.message);
					}
				}
				break;
				
				default:
				callback.statusReceived(err, node.attributes.message);
			}
		}
		private function parseFieldNode(node:XMLNode):void
		{
			var error:String = node.attributes.error;
			var err:int = int(error);
			trace (err.toString());

			switch (state) {
				case StateLogin:
				// skip
				break;
				
				case StatePlay:
				clear();
				for each (var p:XMLNode in node.childNodes) {
					if (p.nodeName == "planting") {
						var posx:int = int(p.attributes.posx);
						var posy:int = int(p.attributes.posy);
						var item:FarmFieldItem = field.item(posx, posy);
						if (item != null) {
							var type:String = p.attributes.type;
							var growth:int = p.attributes.growth;
							var updated:uint = p.attributes.updated;
							//callback.debugString("planting "+posx.toString()+", "+posy.toString()+", "+type+", "+growth.toString());
							item.init(type, growth);
						}
					}
				}
				callback.farmFieldChanged();
				break;
				
			}
		}
		private function parseResponse(response:XML):void
		{
			//dispatchEvent(new Event(FIELDCHANGED));
			
			xDoc.parseXML(response.toXMLString());
			
			if (xDoc.childNodes.length == 1 && xDoc.firstChild.nodeName == "country") {
				var country:XMLNode = xDoc.firstChild;
				for each (var node:XMLNode in country.childNodes) {
					trace(node.nodeName);
					if (node.nodeName == "status") {
						parseStatusNode(node);
					} else if (node.nodeName == "field") {
						parseFieldNode(node);
						//callback.responseReceived(response.toString());
					}
				}
			} else { // bad response ???

			}
			
			
		}
		
		private function sendStatCmd():void
		{
			
		}
		
		public function sendRequest():void
		{
			try {
				server.send(protocol.request);
				waitResponse = true;
			} catch (e:IOError) {
				if (callback) {
					callback.errorIoServer(e.message);
				}
			}
		}

		
		public function GameManager(cb:IGameManagerCallback) 
		{
			callback = cb;
			xDoc.ignoreWhite = true;
			
			field = new FarmField(dimx, dimy);
			
			server.addEventListener(Event.CLOSE, closeHandler, false, 0, true);
			server.addEventListener(Event.CONNECT, connectHandler, false, 0, true);
			server.addEventListener(DataEvent.DATA, dataHandler, false, 0, true);
			server.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
			//server.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
			server.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler, false, 0, true);   
			
			//Log.write("GameManager instantiated");
		}
		
		public function connect(addr:String):Boolean
		{
			var parts:Array = addr.split(':');
			if (parts.length < 1 || parts.length > 2) { return false; }
			var ip:String = parts[0];
			var port:int = 80;
			if (parts.length == 2) {
				port = parseInt(parts[1], 10);
			}
			server.connect(ip, port);
			try {
				Security.loadPolicyFile("xmlsocket://"+addr);
			} catch (e:IOError) {
				trace(e.message);
				return false;
			}
			return true;
		}
		// socket event handlers
		private function securityHandler(e:SecurityErrorEvent):void
		{
		}
		private function closeHandler(e:Event):void
		{
		}
		private function connectHandler(e:Event):void
		{
			dispatchEvent(new Event(CONNECT));
			if (callback) {
				callback.connectToServer();
			}
		}
		private function dataHandler(e:DataEvent):void
		{
			waitResponse = false;
			
			if (callback != null) {
				callback.endServerTransaction();
			}
			
			dispatchEvent(new Event(ENDTRANSACT));//???
			
			 var xml:XML = new XML(e.data);
			 
			if (callback != null) {
				callback.responseReceived(xml.toString());
			}
			 parseResponse(xml);
		}
		private function errorHandler(e:IOErrorEvent):void
		{
			dispatchEvent(new Event(ERROR));
			if (callback) {
				callback.errorIoServer(e.text);
			}
		}
		//
		public function login(user:String, pwd:String = null):void
		{
			loginStr = user;
			state = StateLogin;
			
			protocol.beginRequest();
			protocol.beginCommand("login");
			protocol.addCommandItem([
									["user", user]
									]);
			protocol.endCommand();
			protocol.endRequest();
			sendRequest();
			//callback.requestReady(protocol.request);
		}
		public function logout():void
		{
			loginStr = "";
			state = StateLogout;
			
			protocol.beginRequest();
			protocol.addCommand("logout");
			protocol.endRequest();
			sendRequest();
			//callback.requestReady(protocol.request);
		}
		public function addUser(user:String):void
		{
			loginStr = user;
			state = StateAddUser;
			
			protocol.beginRequest();
			protocol.beginCommand("new");
			protocol.addCommandItem([
									["user", user]
									]);
			protocol.endCommand();
			protocol.endRequest();
			sendRequest();
			//callback.requestReady(protocol.request);
		}
		public function deleteUser(user:String):void
		{
			protocol.beginRequest();
			protocol.addCommand("kill");
			protocol.endRequest();
			sendRequest();
			state = StateAddUser;
			//callback.requestReady(protocol.request);
		}
		public function updateFieldState():void
		{
			protocol.beginRequest();
			protocol.addCommand("stat");
			protocol.endRequest();
			sendRequest();
		}
		// methods
		public function get farmfield(): FarmField { return field; }
		public function select(posx:int, posy:int):Boolean
		{
			var item:FarmFieldItem = field.item(posx, posy);
			if (item != null) {
				if (item.isEmpty()) {
					item.toggleselect();
					return true;
				}
			}
			return false;
		}
		public function multiselect(sx:int, sy:int, ex:int, ey:int):Boolean
		{
			var ret:Boolean = false;
			for (var ix:int = 0; ix < dimx; ++ix) {
				for (var iy:int = 0; iy < dimy; ++iy) {
					var item:FarmFieldItem = field.item(ix, iy);
					if (item != null && item.isEmpty()) {
						if (ix >= sx && ix <= ex && iy >= sy && iy <= ey) {
							item.select();
							ret = true;
						} else if (item.isSelected()) {
							item.toggleselect();
							ret = true;
						}
					}
				}
			}
			return ret;
		}
		public function deselect():Boolean
		{
			var ret:Boolean = false;
			for (var ix:int = 0; ix < dimx; ++ix) {
				for (var iy:int = 0; iy < dimy; ++iy) {
					var item:FarmFieldItem = field.item(ix, iy);
					if (item != null) {
						if (item.isSelected()) {
							item.toggleselect();
							ret = true;
						}
					}
				}
			}
			return ret;
		}
		
		public function clear():void
		{
			for (var ix:int = 0; ix < dimx; ++ix) {
				for (var iy:int = 0; iy < dimy; ++iy) {
					var item:FarmFieldItem = field.item(ix, iy);
					if (item != null) {
						item.clear();
					}
				}
			}
		}
		
		public function seedOne(type:String, posx:int, posy:int):Boolean
		{
			var item:FarmFieldItem = field.item(posx, posy);
			if (item != null) {
				if (item.isEmpty() || (item.isTemporary() && item.type == type)) {
					item.setType(type);
					return true;
				}
			}
			return false;
		}
		
		public function stat():void
		{
			protocol.beginRequest();
			protocol.addCommand("stat");
			protocol.endRequest();
			sendRequest();
		}
		
		public function seed(type:String):Boolean
		{
			protocol.beginRequest();
			protocol.beginCommand("seed");
			
			var ret:Boolean = false;
			for (var ix:int = 0; ix < dimx; ++ix) {
				for (var iy:int = 0; iy < dimy; ++iy) {
					var item:FarmFieldItem = field.item(ix, iy);
					if (item != null && item.isSelected()) {
						item.setType(type);
						ret = true;
						
						protocol.addCommandItem([
												["posx", ix.toString()],
												["posy", iy.toString()],
												["type", type]
												]);
					}
				}
			}
			protocol.endCommand();
			protocol.endRequest();
			sendRequest();
			
			if (callback) {
				callback.requestReady(protocol.request);
			}
			
			return ret;
		}
		
		public function grow():void
		{
			for (var ix:int = 0; ix < dimx; ++ix) {
				for (var iy:int = 0; iy < dimy; ++iy) {
					var item:FarmFieldItem = field.item(ix, iy);
					if (item != null) {
						item.grow();
					}
				}
			}
			
			protocol.beginRequest();
			protocol.addCommand("grow");
			protocol.endRequest();
			sendRequest();
			
			if (callback) {
				callback.requestReady(protocol.request);
			}
		}
		
		public function reap(posx:int, posy:int):Boolean
		{
			var item:FarmFieldItem = field.item(posx, posy);
			if (item != null) {
				item.reap();
				
				protocol.beginRequest();
				protocol.beginCommand("reap");
				protocol.addCommandItem([
										["posx", posx.toString()],
										["posy", posy.toString()]
										]);
				protocol.endCommand();
				protocol.endRequest();
				sendRequest();
				
				if (callback) {
					callback.requestReady(protocol.request);
				}
				return true;
			}

			return false;
		}
	}

}