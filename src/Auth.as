package FirebaseREST.src 
{
	import FirebaseREST.src.events.FBAuthEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class Auth extends EventDispatcher
	{
		private var _session:Session;
		
		private var apiKey:String;
		
		//Used for verification of email and reseting password
		public static const GAPIURL:String = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/";
		public static const SIGN_USER_UP:String = "signupNewUser";
		public static const OOB_CC:String = "getOobConfirmationCode";
		public static const GET_ACCOUNT_INFO:String = "getAccountInfo";
		public static const SET_ACCOUNT_INFO:String = "setAccountInfo";
		public static const DELETE_ACCOUNT:String = "deleteAccount";
		public static const TOKEN_REFRESH:String = "https://securetoken.googleapis.com/v1/token";
		public static const VERIFY_PASSWORD:String = "verifyPassword";
		
		
		public function Auth(apiKey:String) 
		{
			this.apiKey = apiKey;
		}
		
		public function email_login(email:String, password:String):void
		{
			var myObject:Object = new Object();
			myObject.email = email;
			myObject.password = password;
			myObject.returnSecureToken = true;
			
			var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");
			
			var request:URLRequest = new URLRequest(GAPIURL + VERIFY_PASSWORD + "?key=" + apiKey);
			request.method = URLRequestMethod.POST;
			request.data = JSON.stringify(myObject);
			request.requestHeaders.push(header);
			
			var loader:URLLoader = new URLLoader();	
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(Event.COMPLETE, signInComplete);
			loader.load(request);	
		}
		
		private function signInComplete(e:Event):void 
		{
			_session = new Session(JSON.parse(e.currentTarget.data));
			dispatchEvent(new FBAuthEvent(FBAuthEvent.LOGIN_SUCCES, "LOGIN_SUCCESS: \n" + e.currentTarget.data));
		}
		
		private function errorHandler(e:IOErrorEvent):void 
		{
			dispatchEvent(e);
		}
		
		public function get session():Session 
		{
			return _session;
		}
		
	}

}