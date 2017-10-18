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
		
		public static const REALTIME_PUT:String = "put";
		public static const REALTIME_PATCH:String = "patch";
		public static const REALTIME_KEEP_ALIVE:String = "keep-alive";
		public static const REALTIME_CANCEL:String = "cancel";
		public static const REALTIME_AUTH_REVOKED:String = "auth_revoked";
		
		public static const REALTIME_PROGRESS:String = "realtimeProgress";
		
		public static const REALTIME_FAILURE:String = "realtimeFailure";
		
		private var _data:Object;
		private var _node:String;
		
		public function DatabaseEvent(type:String, data:Object = null, node:String=null, bubbles:Boolean = false, cancelable:Boolean = false) 
		{ 
			super(type, bubbles, cancelable);
			_data = data;
			_node = node;
		} 
		
		public override function clone():Event 
		{ 
			return new DatabaseEvent(type, data, node, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("type", "data", "node", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get data():Object 
		{
			return _data;
		}
		
		public function get node():String 
		{
			return _node;
		}
		
	}
	
}