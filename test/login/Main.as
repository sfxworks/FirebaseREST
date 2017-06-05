package FirebaseREST.test.login 
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
			fBCore.auth.email_login("{EMAIL}", "{PASSWORD}");
		
			fBCore.auth.addEventListener(FBAuthEvent.LOGIN_SUCCES, handleFBLoginSuccess);
			fBCore.auth.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
		}
		
		private function handleIOError(e:IOErrorEvent):void 
		{
			trace("IO error");
		}
		
		private function handleFBLoginSuccess(e:FBAuthEvent):void 
		{
			trace(e.message);
		}
		
	}

}