package farm.core 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	import farm.core.ImageLoader;
	import farm.core.ImageLoaderEvent;
	import farm.core.Resources;
	import farm.core.Log;
	
	public class Image
	{
		private var loader:ImageLoader = null;
		private var func:Function = null;
		
		public function Image() 
		{
			
		}
		
		public function getImage(fn:Function, name:String = ""):void
		{
			if (fn == null) {
				if (loader != null) {
					loader.remove(imageLoaded);
					loader = null;
				}
				return;
			}
			if (loader != null) {
				loader.remove(imageLoaded);
				loader = null;
			}
			
			loader = Resources.getImage(name);
			if (loader == null) { // no image found with this name
				fn(null);
				Log.write("no image found with this name");
				return;
			}
			var bmpData:BitmapData = loader.data;
			if (bmpData == null) { // image not loaded yet
				this.func = fn;
				loader.add(imageLoaded);
				Log.write("image not loaded yet");
			} else {
				fn(new Bitmap(bmpData));
				Log.write("image already loaded");
			}
		}
		
		private function imageLoaded(e:ImageLoaderEvent):void
		{
			if (loader != null) {
				loader.remove(imageLoaded);
				loader = null;
			}
			if (func != null) {
				func(new Bitmap(e.data));
			}
		}
	}

}