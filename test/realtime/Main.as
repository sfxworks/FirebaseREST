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
		
		public function Main() 
		{
			super();
			
			fBCore = new Core();
			fBCore.init("key", "pname");
			trace("Init");
			fBCore.auth.addEventListener(AuthEvent.LOGIN_SUCCES, hanldeFBSuccess);
			fBCore.auth.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			
			fBCore.auth.email_login("login", "password1");
		}
		
		private function handleIOError(e:IOErrorEvent):void 
		{
			trace("IOError");
		}
		
		private function hanldeFBSuccess(e:AuthEvent):void 
		{
			trace("Main login success.");
			trace(e.message);
			fBCore.database.readRealTime("stores", true);
			fBCore.database.addEventListener(DatabaseEvent.REALTIME_PUT, handleRealtimePut);
		}
		
		private function handleRealtimePut(e:DatabaseEvent):void 
		{
			trace("Realtime Put.");
			
			trace("Path = " + e.node);
			trace("Data = " + JSON.stringify(e.data));
		}
		
		
	}

}