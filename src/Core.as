package FirebaseREST.src 
{
	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class Core 
	{
		
		private var firebaseAPIKey:String = "";
		private var projectID:String = "";
		
		private static const GAPIURL:String = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/";
		private static const SIGN_USER_UP:String = "signupNewUser";
		//Used for verification of emial and reseting password
		private static const OOB_CC:String = "getOobConfirmationCode";
		private static const GET_ACCOUNT_INFO:String = "getAccountInfo";
		private static const SET_ACCOUNT_INFO:String = "setAccountInfo";
		private static const DELETE_ACCOUNT:String = "deleteAccount";
		private static const TOKEN_REFRESH:String = "https://securetoken.googleapis.com/v1/token";
		
		
		public function Core() 
		{
			
		}
		
		private var init():void
		{
			//Load default jso
		}
		
	}

}