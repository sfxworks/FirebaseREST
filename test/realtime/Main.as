package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLStream;
	import net.sfxworks.firebaseREST.Core;
	import net.sfxworks.firebaseREST.events.AuthEvent;
	import net.sfxworks.firebaseREST.events.DatabaseEvent;
	
	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class Main extends Sprite 
	{
		private var fBCore:Core;
		private var rtsc:URLStream;
		private var progressCounter:int;
		
		public function Main() 
		{
			super();
			progressCounter = 0;
			fBCore = new Core();
			fBCore.init("key", "pname");
			fBCore.database.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			
			trace("Init");
			fBCore.auth.addEventListener(AuthEvent.LOGIN_SUCCES, hanldeFBSuccess);
			fBCore.auth.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			
			fBCore.auth.email_login("login", "password1");
		}
		
		private function handleIOError(e:IOErrorEvent):void 
		{
			trace("IOError");
			trace(e.text);
			trace(e.errorID);
		}
		
		private function hanldeFBSuccess(e:AuthEvent):void 
		{
			trace("Main login success.");
			trace(e.message);
			fBCore.database.readRealTime("", true);
			fBCore.database.addEventListener(DatabaseEvent.REALTIME_PUT, handleRealtimeEvent);
			fBCore.database.addEventListener(DatabaseEvent.REALTIME_PATCH, handleRealtimeEvent);
			//fBCore.database.addEventListener(DatabaseEvent.REALTIME_PROGRESS, handleRealtimeProgress);
			fBCore.database.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
		}
		
		private function handleRealtimeProgress(e:DatabaseEvent):void 
		{
			progressCounter++;
			trace("Parse part " + progressCounter + "/?");
		}
		
		private function handleRealtimeEvent(e:DatabaseEvent):void 
		{
			trace("Realtime " + e.type);
			
			trace("Path = " + e.node);
			//trace("Data = " + JSON.stringify(e.data));
		}
		
		
	}

}