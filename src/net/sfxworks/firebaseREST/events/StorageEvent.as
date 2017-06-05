package net.sfxworks.firebaseREST.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class StorageEvent extends Event 
	{
		
		public static const UPLOAD_COMPLETE:String = "fbuploadcomplete";
		public static const DELETE_COMPLETE:String = "fbdeletecomplte";
		
		private var _data:Object;
		
		public function StorageEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			_data = data;
		} 
		
		public override function clone():Event 
		{ 
			return new StorageEvent(type, data, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("StorageEvent", "type", "data", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get data():Object 
		{
			return _data;
		}
		
	}
	
}