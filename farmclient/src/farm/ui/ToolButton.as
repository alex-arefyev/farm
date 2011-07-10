package farm.ui 
{
	import farm.core.Image;
	import flash.display.Bitmap;
	
	public final class ToolButton extends ImageButton 
	{
		private var img:Image = new Image();
		
		private function imageLoaded(img:Bitmap):void
		{
			super.image = img;
		}
		
		public function ToolButton(bs:String, w:int = 0, h:int = 0) 
		{
			super(null, true, w, h);
			img.getImage(imageLoaded, bs);
		}
		
	}

}