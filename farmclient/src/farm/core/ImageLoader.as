package farm.core 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoaderDataFormat;
	
	import farm.core.ImageLoaderEvent;
	import farm.core.Log;
	
	public final class ImageLoader extends EventDispatcher
	{
		private var imgData:BitmapData = null;
		private var name:String = "";
		private var loader:Loader = null;
		private var error:Boolean = false;
		
		private function handleComplete(e:Event):void
		{
			var bitmapData:BitmapData = new BitmapData(loader.width, loader.height, true, 0x00FFFFFF);
			bitmapData.draw(loader.content);

			imgData = bitmapData;
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader = null;
			
			//Log.write("Image loaded");
			
			dispatchEvent(new ImageLoaderEvent(imgData));
		}
		private function onIOError(e:IOErrorEvent):void
		{
			Log.write("ImageLoader Error: "+e.text);
		}
		
		public function ImageLoader(file:String)
		{
			//Log.write("Loading "+file);
			name = file;
			try {
				var request:URLRequest = new URLRequest(name);
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				loader.load(request);
			} catch (err:Error) {
				Log.write(err.message);
				error = true;
			}
		}

		public function get data():BitmapData
		{
			return imgData;
		}
		public function add(fn:Function):void
		{
			if (fn == null) { return; }
			
			if (imgData != null || error) {
				fn(new ImageLoaderEvent(imgData));
			} else {
				addEventListener(ImageLoaderEvent.IMAGE_LOADED, fn);
			}
		}
		public function remove(fn:Function):void
		{
			removeEventListener(ImageLoaderEvent.IMAGE_LOADED, fn);
		}
	}

}