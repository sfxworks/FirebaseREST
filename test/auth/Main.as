package FirebaseREST.test.auth 
{
	import FirebaseREST.src.Core;
	import FirebaseREST.src.events.FBAuthEvent;
	import flash.display.MovieClip;
	import flash.events.IOErrorEvent;
	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class Main extends MovieClip
	{
		private var fBCore:Core = new Core();
		
		public function Main() 
		{
			fBCore.init("{PROJECT KEY}", "{PROJECT ID}");
			
			fBCore.auth.addEventListener(FBAuthEvent.LOGIN_SUCCES, hanldeFBSuccess);
			fBCore.auth.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			
			//fBCore.auth.register("d1368402@mvrht.net", "4dsfsds");
			
		}
		
		private function handleIOError(e:IOErrorEvent):void 
		{
			trace("IO error");
			trace(e.text);
		}
		
		private function hanldeFBSuccess(e:FBAuthEvent):void 
		{
			trace(e.message);
			//fBCore.auth.resetPassword("d1368402@mvrht.net");
		}
		
	}

}