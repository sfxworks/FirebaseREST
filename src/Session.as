package FirebaseREST.src 
{
	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class Session 
	{
		private var _kind:String;
		private var _idToken:String;
		private var _email:String;
		private var _refreshToken:String;
		private var _expiration:int;
		private var _localId:String;
		
		public function Session(newSession:Object) 
		{
			
		}
		
		public function get kind():String 
		{
			return _kind;
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
		
	}

}