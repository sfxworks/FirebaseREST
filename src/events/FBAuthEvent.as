package FirebaseREST.src.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class FBAuthEvent extends Event 
	{
		private var _message:String;
		
		public static const LOGIN_SUCCES:String = "fbloginsuccess";
		public static const REGISTER_SUCCESS:String = "fbregistersuccess";
		public static const OPERATION_COMPLETE:String = "fboperationcomplete";
		
		public function FBAuthEvent(type:String, message:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			_message = message;
			
			
		} 
		
		public override function clone():Event 
		{ 
			return new FBAuthEvent(_message, type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("FBAuthEvent", "type", "message", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get message():String 
		{
			return _message;
		}
		
	}
	
}