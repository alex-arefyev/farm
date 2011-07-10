package farm.ui 
{
	import flash.events.MouseEvent;
	
	public interface IPlantingOwner
	{
		function plantingClicked(posx:int, posy:int):void;
		function plantingClickMissed(posx:int, posy:int, e:MouseEvent):void;
		function plantingStartDrag(posx:int, posy:int):void;
	}
	
}