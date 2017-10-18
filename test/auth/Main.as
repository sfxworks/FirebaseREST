package
{
	import flash.display.Sprite;
	import net.sfxworks.firebaseREST.events.AuthEvent;
	import net.sfxworks.firebaseREST.Core;
	import flash.events.IOErrorEvent;
	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class Main extends Sprite
	{
		private var fBCore:Core = new Core();
		
		public function Main() 
		{
			fBCore.init("{PROJECT KEY}", "{PROJECT ID}");
			fBCore.auth.addEventListener(AuthEvent.LOGIN_SUCCES, hanldeFBSuccess);
			fBCore.auth.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			
			fBCore.auth.email_login("login@provider.com", "password");			
		}

		private function handleIOError(e:IOErrorEvent):void 
		{
			trace("IO error");
			trace(e.text);
		}
		
		private function hanldeFBSuccess(e:AuthEvent):void 
		{
			trace("Main login success.");
			trace(e.message);
		}
		
	}

}