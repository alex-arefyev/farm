package farm.ui 
{
	
	public interface ILoginCallback 
	{
		function onLoginEnter(s:String):void;
		function onAddUser(s:String):void;
		function onDeleteUser(s:String):void;
	}
	
}