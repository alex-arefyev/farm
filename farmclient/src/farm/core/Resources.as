package farm.core 
{
	import flash.display.Bitmap;
	
	public final class Resources 
	{
		// embedded resources, for local test
		[Embed(source="../../img/check.png")]
		public static var Check:Class;
		[Embed(source="../../img/add.png")]
		public static var Add:Class;
		[Embed(source="../../img/door.png")]
		public static var Door:Class;
		[Embed(source="../../img/tools/cut.png")]
		public static var ToolCut:Class;
		[Embed(source="../../img/tools/watering.png")]
		public static var ToolWatering:Class;
		[Embed(source="../../img/tools/cursorCut.png")]
		public static var CutToolCursor:Class;
		// clover
/*		[Embed(source="../../img/clover/1.png")]
		public static var Clover01:Class;
		[Embed(source="../../img/clover/2.png")]
		public static var Clover02:Class;
		[Embed(source="../../img/clover/3.png")]
		public static var Clover03:Class;
		[Embed(source="../../img/clover/4.png")]
		public static var Clover04:Class;
		[Embed(source="../../img/clover/5.png")]
		public static var Clover05:Class;
		[Embed(source="../../img/clover/cursor.png")]
		public static var CloverToolCursor:Class;
		// potato
		[Embed(source="../../img/potato/1.png")]
		public static var Potato01:Class;
		[Embed(source="../../img/potato/2.png")]
		public static var Potato02:Class;
		[Embed(source="../../img/potato/3.png")]
		public static var Potato03:Class;
		[Embed(source="../../img/potato/4.png")]
		public static var Potato04:Class;
		[Embed(source="../../img/potato/5.png")]
		public static var Potato05:Class;
		[Embed(source="../../img/potato/cursor.png")]
		public static var PotatoToolCursor:Class;
		// Sunflower
		[Embed(source="../../img/sunflower/1.png")]
		public static var Sunflower01:Class;
		[Embed(source="../../img/sunflower/2.png")]
		public static var Sunflower02:Class;
		[Embed(source="../../img/sunflower/3.png")]
		public static var Sunflower03:Class;
		[Embed(source="../../img/sunflower/4.png")]
		public static var Sunflower04:Class;
		[Embed(source="../../img/sunflower/5.png")]
		public static var Sunflower05:Class;
		[Embed(source="../../img/sunflower/cursor.png")]
		public static var SunflowerToolCursor:Class;*/
		
		private static var remoteImages:Object = new Object();
		
		private static var rootUrl:String = "img/";
		
		private static var images:Object = new Object;
		//private function Resources() { }
		//public static var instance:Resources = new Resources();
		
		private static function loadImage(name:String):Bitmap
		{
			// for local test
			if (name == "check") return new Check();
			if (name == "add") return new Add();
			if (name == "door") return new Door();
			if (name == "tools/cut") return new ToolCut();
			if (name == "tools/watering") return new ToolWatering();
			if (name == "tools/cursorCut") return new CutToolCursor();
			// clover
	/*		if (name == "clover/1") return new Clover01();
			if (name == "clover/2") return new Clover02();
			if (name == "clover/3") return new Clover03();
			if (name == "clover/4") return new Clover04();
			if (name == "clover/5") return new Clover05();
			if (name == "clover/cursor") return new CloverToolCursor();
			// potato
			if (name == "potato/1") return new Potato01();
			if (name == "potato/2") return new Potato02();
			if (name == "potato/3") return new Potato03();
			if (name == "potato/4") return new Potato04();
			if (name == "potato/5") return new Potato05();
			if (name == "potato/cursor") return new PotatoToolCursor();
			// sunflower
			if (name == "sunflower/1") return new Sunflower01();
			if (name == "sunflower/2") return new Sunflower02();
			if (name == "sunflower/3") return new Sunflower03();
			if (name == "sunflower/4") return new Sunflower04();
			if (name == "sunflower/5") return new Sunflower05();
			if (name == "sunflower/cursor") return new SunflowerToolCursor();*/
			return null;
			// load images from server
			/*
			 * ...
			 * */
		}
		
		public static function Initialize():void
		{
			remoteImages["bg"] = ["jpg", null];
			remoteImages["check"] = ["png", null];
			remoteImages["add"] = ["png", null];
			remoteImages["delete"] = ["png", null];
			remoteImages["tools/none"] = ["png", null];
			remoteImages["tools/shovel"] = ["png", null];
			remoteImages["tools/watering"] = ["png", null];
			// clover
			remoteImages["clover/1"] = ["png", null];
			remoteImages["clover/2"] = ["png", null];
			remoteImages["clover/3"] = ["png", null];
			remoteImages["clover/4"] = ["png", null];
			remoteImages["clover/5"] = ["png", null];
			// potato
			remoteImages["potato/1"] = ["png", null];
			remoteImages["potato/2"] = ["png", null];
			remoteImages["potato/3"] = ["png", null];
			remoteImages["potato/4"] = ["png", null];
			remoteImages["potato/5"] = ["png", null];
			// sunflower
			remoteImages["sunflower/1"] = ["png", null];
			remoteImages["sunflower/2"] = ["png", null];
			remoteImages["sunflower/3"] = ["png", null];
			remoteImages["sunflower/4"] = ["png", null];
			remoteImages["sunflower/5"] = ["png", null];
		}
		
		public static function getImage(name:String):ImageLoader
		{
			var a:Array = remoteImages[name];
			if (a == null) {
				return null;
			}
			var ldr:ImageLoader = a[1];
			if (ldr == null) {
				ldr = new ImageLoader(rootUrl+name+"."+a[0]);
				a[1] = ldr;
			}
			return ldr;
		}
		
		public static function image(name:String):Bitmap
		{
			var bmp:Bitmap = images[name];
			if (bmp == null) {
				bmp = loadImage(name);
				if (bmp != null) {
					images[name] = bmp;
				}
			}
			return bmp;
		}
		public static function clone(bmp:Bitmap): Bitmap
		{
			if (bmp == null) { return null; }
			return new Bitmap(bmp.bitmapData);
		}
	}

}