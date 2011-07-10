package farm.ui 
{
	import farm.core.FarmFieldItem;
	import farm.core.Image;
	import farm.ui.IPlantingOwner;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public final class Planting extends Sprite
	{
		private var _owner:IPlantingOwner = null;
		private var _posx:int = 0;
		private var _posy:int = 0;
		
		private var img:Image = new Image();
		private var bmp:Bitmap = null;
		private var maskShape:Shape = null;
		private var _type:String;
		private var _growth:int = 1;
		
		private var _width:int = 0;
		private var _height:int = 0;
		private var _ofsx:int = 0;
		private var _ofsy:int = 4;
		
		private var _selected:Boolean = false;
		
		private var _mouseDown:Boolean = false;
		private var _mouseDrag:Boolean = false;
		
		private function draw():void
		{//return;
			graphics.clear();
			
			var alpha:Number = 0.0, alpha2:Number = 0.0;
			if (_selected) {
				alpha = 0.3;
				alpha2 = 0.15;
			}

			if (true) {
				graphics.lineStyle(1,0x000000, alpha);
				graphics.beginFill(0x4CFF00, alpha2);
				graphics.moveTo(0, _height / 2);
				graphics.lineTo(_width / 2, 0);
				graphics.lineTo(_width, _height / 2);
				graphics.lineTo(_width / 2, _height);
				graphics.lineTo(0, _height / 2);
				graphics.endFill();
			}
		}
		private function initMask():void
		{
			if (maskShape == null) {
				var alpha:Number = 0.0;
				maskShape = new Shape();
					maskShape.graphics.beginFill(0, alpha);
					maskShape.graphics.lineStyle(1,0x000000, alpha);
					maskShape.graphics.moveTo(0, _height / 2);
					maskShape.graphics.lineTo(_width / 2, 0);
					maskShape.graphics.lineTo(_width, _height / 2);
					maskShape.graphics.lineTo(_width / 2, _height);
					maskShape.graphics.lineTo(0, _height / 2);
					maskShape.graphics.endFill();

					addChild(maskShape);
					addEventListener(MouseEvent.CLICK, onImageClicked);
					//super.mask = maskShape;
			}
		}
		private function setBitmap(bs:String):void
		{
			img.getImage(imageLoaded, bs);
		}
		private function removeBitmap():void
		{
			if (bmp != null) {
				//bmp.removeEventListener(MouseEvent.CLICK, onImageClicked);
				removeChild(bmp);
				bmp = null;
				super.mask = maskShape;
			}
		}
		
		public function Planting(o:IPlantingOwner, x:int, y:int, bs:String, w:int, h:int, ox:int, oy:int, t:String = "", g:int = 0) 
		{
			_owner = o;
			_posx = x;
			_posy = y;
			
			_width = w;
			_height = h;
			
			_ofsx = ox;
			
			init(bs, t, g);
			
			super.width = _width;
			super.height = _height;
			
			initMask();

			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

			if (stage) initialize();
			else addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		private function initialize(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		}
		
		public function get image(): Bitmap { return bmp; }
		public function get type():String { return _type; }
		public function get growth():int { return _growth; }
		public function isEmpty(): Boolean { return _type.length == 0; }
		public function isSelected(): Boolean { return _selected; }
		public function isTemporary(): Boolean { return _growth == 0; }
		
		public function select(sel:Boolean):void
		{
			if (isEmpty()) {
				_selected = sel;
				draw();
			}
		}
		
		public function init(bs:String, t:String, g:int):void
		{
			_type = t;
			_growth = g;
			_selected = false;
			_ofsy = _growth == 0 ? 4 : 0;
			
			removeBitmap();
			setBitmap(bs);

			draw();
		}
		
		
		public function grow(bs:String, g:int):void
		{
			_growth = g;
			removeBitmap();
			setBitmap(bs);
		}
		
		public function seed():void
		{
			_growth = 1;
			_ofsy = 0;
			if (bmp != null) {
				bmp.y = _height - bmp.height - _ofsy;
			}
		}
		
		public function reap():void
		{
			_growth = -1;
			if (bmp != null) {
				bmp.alpha = 0.65;
			}
		}
		
		public function clear():void
		{
			_type = "";
			_growth = 0;

			removeBitmap();

			draw();
		}
		
		private function imageLoaded(b:Bitmap):void
		{
			if (b != null) {
				removeBitmap();
				bmp = b;
				bmp.x = _ofsx;
				bmp.y = _height - bmp.height - _ofsy;
				//bmp.addEventListener(MouseEvent.CLICK, onImageClicked);
				addChild(bmp);
				
				if (_growth == -1) {
					bmp.alpha = 0.6;
				}
				//bmp.visible = false;
				
				super.mask = null;
				
				draw();
			}
		}
		
		private function onImageClicked(e:MouseEvent):void
		{
			var b:Boolean = true;
			if (bmp != null) {
				//if (!bmp.hitTestPoint(e.stageX, e.stageY)) { return; }
				b = bmp.bitmapData.getPixel(e.localX - bmp.x, e.localY - bmp.y) != 0;
			} else if (maskShape != null) {
				//if (!hitTestPoint(e.stageX, e.stageY)) { return; }
				b = maskShape.hitTestPoint(e.stageX, e.stageY);
			} else { return; }
			
			if (b) {
				if (_owner != null) {
					trace("onImageClicked() " + String(_posx) + ", " + String(_posy));
					_owner.plantingClicked(_posx, _posy);
				}
			} else {
				if (_owner != null) {
					_owner.plantingClickMissed(_posx, _posy, e);
				}
			/*	var point:Point = new Point(e.stageX, e.stageY);
				var idx:int = parent.getChildIndex(this);
				if (idx > 0) {
					var obj:DisplayObject = parent.getChildAt(idx - 1);
					if (obj != null) {
						var pt:Point = obj.globalToLocal(point);
						obj.dispatchEvent(new MouseEvent(MouseEvent.CLICK, false, false, pt.x, pt.y));
					}
				}*/
			}
		}
		public function processMouseClick(stageX:int, stageY:int):Boolean
		{
			var b:Boolean = false;
			if (bmp != null) {
				if (!bmp.hitTestPoint(stageX, stageY)) { return false; }
				var pt:Point = super.globalToLocal(new Point(stageX, stageY));
				b = bmp.bitmapData.getPixel(pt.x - bmp.x, pt.y - bmp.y) != 0;
			} else if (maskShape != null) {
				if (!hitTestPoint(stageX, stageY)) { return false; }
				b = maskShape.hitTestPoint(stageX, stageY);
			}
			if (b) {
				if (_owner != null) {
					_owner.plantingClicked(_posx, _posy);
				}
				return true;
			}
			return false;
		}
		public function plantingStartDrag(posx:int, posy:int):void
		{
			
		}
		
		// mouse event handlers
		private function onMouseDown(e:MouseEvent):void
		{
			_mouseDown = true;
		}
		private function onMouseMove(e:MouseEvent):void
		{
			if (_mouseDown && !_mouseDrag) {
				_mouseDrag = true;
				if (_owner != null) {
					_owner.plantingStartDrag(e.stageX, e.stageY);
				}
			}
		}
		private function onStageMouseUp(e:MouseEvent):void
		{
			_mouseDown = false;
			_mouseDrag = false;
		}
	}

}