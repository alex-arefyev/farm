package farm.core 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	public final class ImageLoaderEvent extends Event 
	{
		public static const IMAGE_LOADED:String = "image_loaded";
		
		private var bmpData:BitmapData = null;
		
		public function ImageLoaderEvent(bd:BitmapData) 
		{
			super(IMAGE_LOADED, false, false);
			this.bmpData = bd;
		}
		
		public function get data():BitmapData { return bmpData; }
		
	}

}