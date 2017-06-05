package net.sfxworks.firebaseREST.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class DatabaseEvent extends Event 
	{
		public static const DATA_READ:String = "fbdataread";
		public static const DATA_WRITTEN:String = "fbdatawritten";
		public static const UPDATE_COMPLETE:String = "fbupdatecomplete";
		public static const DATA_DELETED:String = "fbdatadeleted";
		private var _data:Object;
		
		public function DatabaseEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) 
		{ 
			super(type, bubbles, cancelable);
			_data = data;
			
		} 
		
		public override function clone():Event 
		{ 
			return new DatabaseEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("DatabaseEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get data():Object 
		{
			return _data;
		}
		
	}
	
}