package net.sfxworks.firebaseREST 
{
	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class Session 
	{
		private var _idToken:String;
		private var _email:String;
		private var _refreshToken:String;
		private var _expiration:int;
		private var _localId:String;
		private var _accessToken:String;
		private var _userID:String;
		private var _displayName:String;
		private var _registered:Boolean;
		
		public function Session(newSession:Object) 
		{
			_refreshToken = newSession.refreshToken;
			_email = newSession.email;
			_displayName = newSession.displayName;
			_expiration = newSession.expiresIn;
			_idToken = newSession.id_token;
			_registered = newSession.registered;
			
		}
		
		public function appendAuth(authReturn:Object):void
		{
			_accessToken = authReturn.access_token;
			_expiration = parseInt(authReturn.expires_in);
			_userID = authReturn.user_id;
		}
		
		public function get idToken():String 
		{
			return _idToken;
		}
		
		public function get email():String 
		{
			return _email;
		}
		
		public function get refreshToken():String 
		{
			return _refreshToken;
		}
		
		public function get expiration():int 
		{
			return _expiration;
		}
		
		public function get localId():String 
		{
			return _localId;
		}
		
		public function get userID():String 
		{
			return _userID;
		}
		
		public function get displayName():String 
		{
			return _displayName;
		}
		
		public function get registered():Boolean 
		{
			return _registered;
		}
		
		public function get accessToken():String 
		{
			return _accessToken;
		}
		
	}

}