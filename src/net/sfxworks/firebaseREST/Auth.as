package net.sfxworks.firebaseREST 
{
	import net.sfxworks.firebaseREST.events.AuthEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class Auth extends EventDispatcher
	{
		private var _session:Session;
		
		private var apiKey:String;
		private var accessToken:String;
		
		//Used for verification of email and reseting password
		public static const GAPIURL:String = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/";
		public static const SIGN_USER_UP:String = "signupNewUser";
		public static const OOB_CC:String = "getOobConfirmationCode";
		public static const GET_ACCOUNT_INFO:String = "getAccountInfo";
		public static const SET_ACCOUNT_INFO:String = "setAccountInfo";
		public static const DELETE_ACCOUNT:String = "deleteAccount";
		public static const TOKEN_REFRESH:String = "https://securetoken.googleapis.com/v1/token";
		public static const VERIFY_PASSWORD:String = "verifyPassword";
		
		private var loggedIn:Boolean;
		
		public function Auth(apiKey:String) 
		{
			this.apiKey = apiKey;
			loggedIn = false;
		}
		
		public function email_login(email:String, password:String):void
		{
			loggedIn = false;
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
		
		public function register(email:String, password:String):void
		{
			loggedIn = false;
			var myObject:Object = new Object();
			myObject.email = email;
			myObject.password = password;
			myObject.returnSecureToken = true;
			
			var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");
			
			var request:URLRequest = new URLRequest(GAPIURL + SIGN_USER_UP + "?key="+apiKey);
			request.method = URLRequestMethod.POST;
			request.data = JSON.stringify(myObject);
			request.requestHeaders.push(header);
			
			var loader:URLLoader = new URLLoader();	
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(flash.events.Event.COMPLETE, registerComplete);
			loader.load(request);
		}
		
		private function registerComplete(e:Event):void 
		{
			e.target.removeEventListener(Event.COMPLETE, registerComplete);
			
			dispatchEvent(new AuthEvent(AuthEvent.REGISTER_SUCCESS, e.currentTarget.data));
			_session = new Session(JSON.parse(e.currentTarget.data));
			setupSessionTimer();
		}
		
		private function signInComplete(e:Event):void 
		{
			e.target.removeEventListener(Event.COMPLETE, signInComplete);
			
			dispatchEvent(new AuthEvent(AuthEvent.OPERATION_COMPLETE, e.currentTarget.data));
			_session = new Session(JSON.parse(e.currentTarget.data));
			setupSessionTimer();
		}
		
		private function setupSessionTimer():void
		{
			var t:Timer = new Timer(_session.expiration * 1000);
			t.addEventListener(TimerEvent.TIMER, sessionTimer);
			t.start();
			refreshAccessToken();
		}
		
		private function sessionTimer(e:TimerEvent):void 
		{
			refreshAccessToken();
		}
		
		private function refreshAccessToken():void
		{
			var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");
			
			var myObject:Object = new Object();
			myObject.grant_type = "refresh_token";
			myObject.refresh_token = _session.refreshToken;			
			
			var request:URLRequest = new URLRequest(TOKEN_REFRESH + "?key="+apiKey);
			request.method = URLRequestMethod.POST;
			request.data = JSON.stringify(myObject);
			request.requestHeaders.push(header);
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, refreshTokenLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(request);	
		}
		
		private function refreshTokenLoaded(e:Event):void 
		{
			_session.appendAuth(JSON.parse(e.currentTarget.data));
			dispatchEvent(new AuthEvent(AuthEvent.AUTH_CHANGE, ""));
			if (loggedIn == false)
			{
				dispatchEvent(new AuthEvent(AuthEvent.LOGIN_SUCCES, "LOGIN_SUCCESS: \n" + e.currentTarget.data));
				loggedIn = true;
			}
		}
		
		
		//Operations:
		
		public function resetPassword(email:String):void
		{
			var myObject:Object = new Object();
			myObject.email = email;
			myObject.requestType = "PASSWORD_RESET";
			
			var header:URLRequestHeader = new URLRequestHeader("Content-Type", "application/json");
			
			var request:URLRequest = new URLRequest(GAPIURL + OOB_CC + "?key="+apiKey);
			request.method = URLRequestMethod.POST;
			request.data = JSON.stringify(myObject);
			request.requestHeaders.push(header);
			
			var loader:URLLoader = new URLLoader();	
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(Event.COMPLETE, resetPasswordComplete);
			loader.load(request);
		}
		
		private function resetPasswordComplete(e:Event):void 
		{
			e.target.removeEventListener(Event.COMPLETE, resetPasswordComplete);
			dispatchEvent(new AuthEvent(AuthEvent.OPERATION_COMPLETE, "password"));
		}
		
		
		
		
		private function errorHandler(e:IOErrorEvent):void 
		{
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			dispatchEvent(e);
		}
		
		public function get session():Session 
		{
			return _session;
		}
		
	}

}