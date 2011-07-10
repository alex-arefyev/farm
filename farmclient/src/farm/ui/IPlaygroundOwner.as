package farm.ui 
{
	
	public interface IPlaygroundOwner 
	{
		function plantingClicked(posx:int, posy:int):void;
		function plantingSelectionStarted(posx:int, posy:int):void;
		function plantingSelectionUpdated(posx:int, posy:int, sx:int, sy:int):void;
	}
	
}