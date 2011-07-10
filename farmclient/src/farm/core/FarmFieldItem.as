package farm.core 
{

	public class FarmFieldItem 
	{
		private var _type:String;
		private var _growth:int = 0; // 0(temporary), 1..5
		private var _selected:Boolean = false;
		
		public function FarmFieldItem(t:String = "", g:int = 0) 
		{
			_type = t;
			_growth = g;
		}
		
		public function init(t:String, g:int):void
		{
			_type = t;
			_growth = g;
		}
		
		public function setType(t:String):void
		{
			if (t == _type && _growth == 0) {
				_growth = 1;
			} else {
				_type = t;
				_growth = 0;
			}
			_selected = false;
		}
		
		public function reap():void
		{
			_growth = -1;
		}
		
		public function clear():void
		{
			_type = "";
			_growth = 0;
			_selected = false;
		}
		
		public function toString():String
		{
			var g:int = _growth == 0 ? 1 : _growth;
			return _type + "/" + g.toString();
		}
		
		public function isEmpty():Boolean { return _type.length == 0; }
		public function isTemporary():Boolean { return _growth == 0; }
		public function isEqual(t:String, g:int):Boolean { return (_type == t && _growth == g); }
		public function get type():String { return _type; }
		public function get growth():int { return _growth; }
		public function toggleselect():void { _selected = !_selected; }
		public function select():void { _selected = true; }
		public function isSelected():Boolean { return _selected; }
		public function isReapping():Boolean { return (!isEmpty() && _growth == -1); }
		public function isSeeding():Boolean { return (!isEmpty() && _growth == 0); }
		public function grow():Boolean
		{
			if (_growth < 5) { // 5 <- ???
				++_growth;
				return true;
			} /*else if (_growth == 5) {
				_growth = 0;
				_type = "";
				return true;
			}*/
			return false;
		}
	}

}