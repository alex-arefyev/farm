package farm.core 
{
	
	public interface IGameManagerCallback 
	{
		function connectToServer():void;
		function reconnectToServer():void;
		function errorIoServer(s:String):void;
		function beginServerTransaction():void;
		function endServerTransaction():void;
		function statusReceived(val:int, msg:String):void;
		function loggedIn():void;
		function loginFailed(val:int, msg:String):void;
		function loggedOut():void;
		function logoutFailed(val:int, msg:String):void;
		function farmFieldChanged():void;
		
		function requestReady(s:String):void;
		function responseReceived(s:String):void;
		function debugString(s:String):void;
	}
	
}