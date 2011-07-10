package farm.core 
{
	import farm.core.FarmFieldItem;
	
	public class FarmField
	{
		private var items:Array = null;
		private var _dimx:int = 0;
		private var _dimy:int = 0;
		
		public function FarmField(dx:int, dy:int)
		{
			items = new Array();
			_dimx = dx;
			_dimy = dy;
			for (var ix:int = 0; ix < _dimx; ++ix) {
				var row:Array = new Array();
				for (var iy:int = 0; iy < _dimy; ++iy) {
					row.push(new FarmFieldItem());
				}
				items.push(row);
			}
		}
		public function get dimx(): int { return _dimx; }
		public function get dimy(): int { return _dimy; }
		
		public function item(x:int, y:int): FarmFieldItem
		{
			if (items != null && 0 <= x && x < _dimx && 0 <= y && y < _dimy) {
				return items[x][y];
			}
			return null;
		}
	}

}