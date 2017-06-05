package FirebaseREST.src 
{
	import FirebaseREST.src.events.AuthEvent;

	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class Core 
	{
		
		private var _firebaseAPIKey:String = "";
		private var _projectID:String = "";
		
		private var _auth:Auth;
		private var _database:Database;
		
		public function Core() 
		{
			
		}
		
		public function init(firebaseAPIKey:String, projectID:String):void
		{
			_firebaseAPIKey = firebaseAPIKey;
			_projectID = _projectID;
			
			_auth = new Auth(firebaseAPIKey);
			_auth.addEventListener(AuthEvent.AUTH_CHANGE, handleAuthChange);
			_database = new Database(projectID);
		}
		
		private function handleAuthChange(e:AuthEvent):void 
		{
			//Pass to database, storage, others..
			_database.authChange(_auth.session.accessToken);
		}
		
		
		public function get auth():Auth 
		{
			return _auth;
		}
		
		public function get database():Database 
		{
			return _database;
		}
		
	}

}