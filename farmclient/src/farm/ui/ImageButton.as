package farm.ui 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	
	public class ImageButton extends Sprite 
	{
		private var bitmap:Bitmap = null;
		private var border:Boolean = false;
		
		
		public function ImageButton(b:Bitmap, brd:Boolean = false, w:int = 0, h:int = 0) 
		{
			super();
			
			border = brd;
			
			if (b != null) {
				
				bitmap = b;

				var brdWidth:int = border ? 10 : 0;
				
				if (w == 0) { w = bitmap.width + brdWidth; }
				if (h == 0) { h = bitmap.height + brdWidth; }
				
				addChild(bitmap);
				bitmap.x = (w - bitmap.width) / 2;
				bitmap.y = (h - bitmap.height) / 2;
			}
			
			if (border) {
				graphics.beginFill(0x303030);
				graphics.drawRoundRect(0, 0, w, h, 20, 20);
				graphics.beginFill(0x7F7F7F);
				graphics.drawRoundRect(3, 3, w - 6, h - 6, 15, 15);
				graphics.endFill();
			} else {
				graphics.beginFill(0, 0);
				graphics.drawRect(0, 0, w, h);
				graphics.endFill();
			}
			super.buttonMode = true;
			super.filters.push(new DropShadowFilter());
		}
		
		public function get image(): Bitmap { return bitmap; }
		
		public function set image(b:Bitmap):void
		{
			if (b != null) {
				
				bitmap = b;
				var brdWidth:int = border ? 10 : 0;
				
				if (super.width == 0 || super.height == 0) {
					
					var w:int = bitmap.width + brdWidth;
					var h:int = bitmap.height + brdWidth;
					
					if (border) {
						graphics.beginFill(0x303030);
						graphics.drawRoundRect(0, 0, w, h, 20, 20);
						graphics.beginFill(0x7F7F7F);
						graphics.drawRoundRect(3, 3, w - 6, h - 6, 15, 15);
						graphics.endFill();
					} else {
						graphics.beginFill(0, 0);
						graphics.drawRect(0, 0, w, h);
						graphics.endFill();
					}
				}

				addChild(bitmap);
				bitmap.x = (super.width - bitmap.width) / 2;
				bitmap.y = (super.height - bitmap.height) / 2;
			}
		}
	}

}