package farm.ui 
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import farm.core.Resources;
	import farm.core.FarmField;
	import farm.core.FarmFieldItem;
	import farm.core.Image;
	import farm.ui.Planting;
	import farm.ui.IPlantingOwner;

	public final class Playground extends Sprite implements IPlantingOwner
	{
		private var owner:IPlaygroundOwner = null;
		
		private var image:Image = new Image();
		
		private var bmp:Bitmap = null;
		private var bmpWidth:int = 0;
		private var bmpHeight:int = 0;
		
		private var field:Array = null;
		private var dimx:int = 0;
		private var dimy:int = 0;
		private var ofsx:int = 0;
		
		private var fieldLeftX:int = 0;
		private var fieldLeftY:int = 0;
		private var fieldTopX:int = 0;
		private var fieldTopY:int = 0;
		private var plantingWidth:int = 0;
		private var plantingHeight:int = 0;

		// planting selection
		private var selectionWidget:Sprite = null;
		private var mouseDown:Boolean = false;
		private var selecting:Boolean = false;
		private var dragging:Boolean = false;
		private var startLeftTop:Point = new Point();
		private var startMousePos:Point = new Point();
		// selection coord helpers
		private var __k:Number = 0.0;
		private var __fs:Number = 0.0;//field side length
		private var __ss:Number = 0.0;//planting side length
		private var __Xr:Number = 0.0;
		private var __Yr:Number = 0.0;
		private var __ptStartReal:Point = new Point();
		private var __ptXyReal:Point = new Point();
		//private var __startIndex:Point = new Point();
		private var __startIndexX:int = 0, __startIndexY:int = 0;
		private var __endIndexX:int = 0, __endIndexY:int = 0;
		//private var __endIndex:Point = new Point();
		private var __fieldLeftPoint:Point = new Point();
		private var __ptLocal:Point = new Point();
		
		private function stageToLocal(stageX:Number, stageY:Number, ptOut:Point):void
		{
			ptOut.x = stageX - super.x;
			ptOut.y = stageY - super.y;
		}
		
		private function calcRealCoords(x:Number, y:Number, ptOut:Point):void
		{
			// TODO optimize calculations
			var dY:Number = y - __fieldLeftPoint.y;
			var dYk:Number = dY * __k;
			var m:Number = (2 * __ss * dY) / plantingHeight;
			var Yr_:Number = (m * ((x - __fieldLeftPoint.x) - dYk)) / (2 * dYk);
			ptOut.x = Yr_ + m;
			ptOut.y = __fs - Yr_;
		}
		
		private function startIndexFromRealCoords(ptReal:Point):void
		{
			if (dimx == 0 || dimy == 0) {
				__startIndexX = 0;
				__startIndexY = 0;
				return;
			}
			var dw:Number = __fs / dimx;
			var dh:Number = __fs / dimy;
			
			__startIndexX = ptReal.x / dw;
			__startIndexY = ptReal.y / dh;
		}
		
		private function endIndexFromRealCoords(ptReal:Point):Boolean
		{
			if (dimx == 0 || dimy == 0) {
				__endIndexX = 0;
				__endIndexY = 0;
				return false;
			}
			var dw:Number = __fs / dimx;
			var dh:Number = __fs / dimy;
			
			var newStartIdxX:int = 0, newStartIdxY:int = 0;
			var newEndIdxX:int = 0, newEndIdxY:int = 0;
			
			if (ptReal.x < __ptStartReal.x) {
				newStartIdxX = (ptReal.x + dw / 2) / dw;
				newEndIdxX = (__ptStartReal.x - dw / 2) / dw;
			} else {
				newStartIdxX = (__ptStartReal.x + dw / 2) / dw;
				newEndIdxX = (ptReal.x - dw / 2) / dw;
			}
			
			if (ptReal.y < __ptStartReal.y) {
				newStartIdxY = (ptReal.y + dh / 2) / dh;
				newEndIdxY = (__ptStartReal.y - dh / 2) / dh;
			} else {
				newStartIdxY = (__ptStartReal.y + dh / 2) / dh;
				newEndIdxY = (ptReal.y - dh / 2) / dh;
			}
			
			if (newStartIdxX == __startIndexX && newStartIdxY == __startIndexY &&
				newEndIdxX == __endIndexX && newEndIdxY == __endIndexY)
				{ return false; }
				
			__startIndexX = newStartIdxX;
			__startIndexY = newStartIdxY;
			__endIndexX = newEndIdxX;
			__endIndexY = newEndIdxY;
			return true;
		}

		private function init(fld:FarmField):void
		{
			var ix:int = 0, iy:int = 0, item:FarmFieldItem = null, plnt:Planting = null;
			field = new Array();
			dimx = fld.dimx;
			dimy = fld.dimy;
			for (ix = 0; ix < dimx; ++ix) {
				var row:Array = new Array();
				for (iy = 0; iy < dimy; ++iy) {
					item = fld.item(ix, iy);
					var bs:String = "";
					if (!item.isEmpty()) {
						bs = item.toString();
					}
					plnt = new Planting(this, ix, iy, bs, plantingWidth-1, plantingHeight-1, ofsx, 0, item.type, item.growth);
					row.push(plnt);
					plnt.x = 300;
					addChild(plnt);
				}
				field.push(row);
			}
		}
		
		private function arrange():void
		{
			var sx:int = fieldTopX - plantingWidth / 2;
			var sy:int = fieldTopY;
			
			//var dx:int = (int)(plantingWidth / 2.0 + .5);
			//var dy:int = (int)(plantingHeight / 2.0 + .5);
			var dx:int = (int)(plantingWidth / 2);
			var dy:int = (int)(plantingHeight / 2);
			
			for (var ix:int = 0; ix < dimx; ++ix) {
				var x:int = sx;
				var y:int = sy;
				for (var iy:int = 0; iy < dimy; ++iy) {
					var plnt:Planting = field[ix][iy];
					if (plnt != null) {
						plnt.x = x;
						plnt.y = y;
					}
					x -= dx;
					y += dy;
				}
				sx += dx;
				sy += dy;
			}
		}
		
		private function imageLoaded(img:Bitmap):void
		{
			if (img != null) {
				bmp = img;
				addChildAt(img, 0);
			}
		}
		
		public function Playground(o:IPlaygroundOwner, img:Bitmap, leftX:int, leftY:int, topX:int, topY:int, cw:Number, ch:Number, ox:int)
		{
			owner = o;
			//image = img;
			fieldLeftX = leftX;
			fieldLeftY = leftY;
			fieldTopX = topX;
			fieldTopY = topY;
			plantingWidth = cw;
			plantingHeight = ch;
			ofsx = ox;
			__k = cw / ch;
			var fw:Number = (topX - leftX) * 2, fh:Number = (leftY - topY) * 2
			__ss = Math.sqrt(cw * cw + ch * ch) / 2.0;
			__fs = Math.sqrt(fw * fw + fh * fh) / 2.0;
			
			image.getImage(imageLoaded, "bg");
			
			// !!!
			__fieldLeftPoint.x = leftX;
			__fieldLeftPoint.y = leftY;
			
			if (bmp != null) {
				bmpWidth = bmp.width;
				bmpHeight = bmp.height;
				graphics.beginBitmapFill(bmp.bitmapData);
				graphics.endFill();
				addChild(bmp);
			} else {
				bmp = new Bitmap();
				graphics.beginFill(0xC0C0C0);
				graphics.endFill();
			}
			
			//addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			if (stage != null) initialize();
			else addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		
		private function initialize(e:Event = null):void
		{
			stage.addEventListener(Event.RESIZE, onStageResize);
			super.x = -30;
			super.y = -30;
		}
		
		private function onStageResize(e:Event):void
		{
			if (super.x + super.width < stage.stageWidth && super.x < 0) {
				super.x = stage.stageWidth - super.width;
				if (super.x > 0) { super.x = (stage.stageWidth - super.width) / 2; }
			}
			if (super.y + super.height < stage.stageHeight && super.y < 0) {
				super.y = stage.stageHeight - super.height;
				if (super.y > 0) { super.y = (stage.stageHeight - super.height) / 2; }
			}
			//trace("stage size: " + stage.stageWidth + " x " + stage.stageHeight);
		}
		
		
		public function imageWidth(): int { return bmp.width; } 
		public function imageHeight(): int { return bmp.height; } 
		
		
		public function sync(fld:FarmField):void
		{
			var ix:int = 0, iy:int = 0, item:FarmFieldItem = null, plnt:Planting = null;
			if (field == null || dimx != fld.dimx || dimy != fld.dimy) {
				init(fld);
			} else {
				for (ix = 0; ix < fld.dimx; ++ix) {
					for (iy = 0; iy < fld.dimy; ++iy) {
						item = fld.item(ix, iy);
						plnt = field[ix][iy];
						if (item == null) { // ???
							plnt.clear();
						} else if (item.isReapping()) { // about to reap
							plnt.reap();
						} else if (item.isEmpty()) {
							if (!plnt.isEmpty()) {
								plnt.clear();
							}
							plnt.select(item.isSelected());
						} else {
							if (item.isSeeding()) {
								plnt.init(item.toString(), item.type, item.growth);
							} else {
								if (plnt.isTemporary()) {
									if (item.type == plnt.type) {
										plnt.seed();
									} else {
										plnt.init(item.toString(), item.type, item.growth);
									}
								} else if (plnt.isEmpty()) {
									plnt.init(item.toString(), item.type, item.growth);
								} else if (!item.isEqual(plnt.type, plnt.growth)) { // grown 1 step
									plnt.grow(item.toString(), item.growth);
								}
							}
						}
					}
				}
			}
			arrange();
		}
		
		// selection event handlers
		private function onSelectionMove(e:MouseEvent):void
		{
			if (mouseDown) {
				stageToLocal(e.stageX, e.stageY, __ptLocal);
				
				if (!selecting) {
					selecting = true;
					calcRealCoords(__ptLocal.x, __ptLocal.y, __ptStartReal);
					__fieldLeftPoint = localToGlobal(new Point(__fieldLeftPoint.x-super.x, __fieldLeftPoint.y-super.y)); 
					if (owner) {
						startIndexFromRealCoords(__ptStartReal);
						owner.plantingSelectionStarted(__startIndexX, __startIndexY);
					}
				}
				if (selecting) {
					var x2:int = e.stageX - startMousePos.x;
					var y2:int = e.stageY - startMousePos.y;
					var dX:int = x2, dY:int = y2;
					var X:Number = dX + dY * __k;
					var dYk:Number = dY * __k;
					var Xbottom:Number = (dX + dY * __k) / 2;
					var Xtop:Number = (dX - dY * __k) / 2;
					var Ybottom:Number = Xbottom / __k;
					var Ytop:Number = -Xtop / __k;
					// TODO optimize calculations
					selectionWidget.graphics.clear();
					selectionWidget.graphics.lineStyle(1,0x000000, 0.3);
					selectionWidget.graphics.beginFill(0x4CFF00, 0.15);
					selectionWidget.graphics.moveTo(0, 0);
					selectionWidget.graphics.lineTo(Xtop, Ytop);
					selectionWidget.graphics.lineTo(x2, y2);
					selectionWidget.graphics.lineTo(Xbottom, Ybottom);
					selectionWidget.graphics.lineTo(0, 0);
					selectionWidget.graphics.endFill();
		/*			
					// TODO optimize calculations
					dY = e.stageY - __fieldLeftPoint.y;
					dYk = dY * __k;
					var m:Number = (2 * __ss * dY) / plantingHeight;
					var Yr_:Number = (m * (dX - dYk)) / (2 * dYk);
					__Xr = Yr_ + m;
					__Yr = __fs - Yr_;
			*/		
					calcRealCoords(__ptLocal.x, __ptLocal.y, __ptXyReal);
					if (endIndexFromRealCoords(__ptXyReal) && owner != null) {
						owner.plantingSelectionUpdated(__startIndexX, __startIndexY, __endIndexX, __endIndexY);
					}
					//trace(__ptXyReal.x.toString() + "," + __ptXyReal.y.toString());
				}
			}
		}
		private function onSelectionUp(e:MouseEvent):void
		{
			mouseDown = false;
			selecting = false;
			if (selectionWidget != null) {
				stage.removeChild(selectionWidget);
				selectionWidget = null;
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSelectionMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onSelectionUp);
			}
		}
		// mouse event handlers
		private function startSelect(x:int, y:int):void
		{
			mouseDown = true;
			startMousePos.x = x;
			startMousePos.y = y;
			
			if (selectionWidget != null) {
				trace("WARNING: selectionWidget is NOT null");
				removeChild(selectionWidget);
			}
			selectionWidget = new Sprite();
			stage.addChild(selectionWidget);
			selectionWidget.x = x;
			selectionWidget.y = y;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSelectionMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onSelectionUp);
		}
		private function onMouseClick(e:MouseEvent):void
		{
		/*	if (owner != null) {
				owner.deselect();
			}*/
		}
		private function isRPointInField(rpt:Point):Boolean
		{
			return (rpt.x >= 0 && rpt.y >= 0 && rpt.x <= __fs && rpt.y <= __fs);
		}
		private function isRPointOutField(rpt:Point):Boolean
		{
			return (rpt.x < 0 || rpt.y < 0 || rpt.x > __fs || rpt.y > __fs);
		}
		private function onMouseDown(e:MouseEvent):void
		{
			if (!selecting) {
				var pt:Point = new Point();
				stageToLocal(e.stageX, e.stageY, __ptLocal);
				calcRealCoords(__ptLocal.x, __ptLocal.y, pt);
				if (isRPointOutField(pt))
				{
					mouseDown = true;
					stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseDragMove);
					stage.addEventListener(MouseEvent.MOUSE_UP, onMouseDragUp);
				}
			}
		}
		private function onMouseDragMove(e:MouseEvent):void
		{
			if (mouseDown) {
				if (!dragging) {
					dragging = true;
					startMousePos.x = e.stageX;
					startMousePos.y = e.stageY;
					startLeftTop.x = super.x;
					startLeftTop.y = super.y;
					return;
				}
				if (dragging) {
					var dx:Number = e.stageX - startMousePos.x;
					var dy:Number = e.stageY - startMousePos.y;
					
					if (stage.stageWidth < super.width) {
						var x:int = startLeftTop.x + dx;
						if (x > 0) { x = 0; }
						else if (x + super.width < stage.stageWidth)
						{
							x = stage.stageWidth - super.width;
						}
						if (super.x != x) {
							super.x = x;
						}
					}
					
					if (stage.stageHeight < super.height) {
						var y:int = startLeftTop.y + dy;
						if (y > 0) { y = 0; }
						else if (y + super.height < stage.stageHeight)
						{
							y = stage.stageHeight - super.height;
						}
						if (super.y != y) {
							super.y = y;
						}
					}					
				}
			}
		}
		private function onMouseDragUp(e:MouseEvent):void
		{
			mouseDown = false;
			dragging = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseDragMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseDragUp);
			
			trace("onMouseDragUp()");
		}
		
		// IPlantingOwner
		public function plantingClicked(posx:int, posy:int):void
		{
			if (owner != null) {
				owner.plantingClicked(posx, posy);
			}
		}
		public function plantingClickMissed(posx:int, posy:int, e:MouseEvent):void
		{
			var ix:int = 0, iy:int = 0, b:Boolean = false;
			var p:Planting = null, px:int = posx, py:int = posy;
			
			for (var i:int  = 0; i < 2; ++i) {
				px = posx;
				py = posy;
				
				if (px > 0) {
					ix = px - 1;
					p = field[ix][py];
					if (p != null) {
						b = p.processMouseClick(e.stageX, e.stageY);
					}
				}
				if (!b && py > 0) {
					iy = py - 1;
					p = field[px][iy];
					if (p != null) {
						b = p.processMouseClick(e.stageX, e.stageY);
					}
				}
				if (!b && px > 0 && py > 0) {
					ix = px - 1;
					iy = py - 1;
					p = field[ix][iy];
					if (p != null) {
						b = p.processMouseClick(e.stageX, e.stageY);
					}
				}
				posx -= 1;
				posy -= 1;
			}
		}
		public function plantingStartDrag(x:int, y:int):void
		{
			startSelect(x, y);
		}
	}

}