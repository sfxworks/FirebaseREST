package FirebaseREST.src 
{

	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class Core 
	{
		
		private var _firebaseAPIKey:String = "";
		private var _projectID:String = "";
		
		private var _auth:Auth;
		
		public function Core() 
		{
			
		}
		
		public function init(firebaseAPIKey:String, projectID:String):void
		{
			_firebaseAPIKey = firebaseAPIKey;
			_projectID = _projectID;
			
			_auth = new Auth(firebaseAPIKey);
		}
		
		
		public function get auth():Auth 
		{
			return _auth;
		}
		
	}

}