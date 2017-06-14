package net.sfxworks.firebaseREST 
{
	import flash.events.ProgressEvent;
	import flash.net.URLStream;
	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class RealtimeObject
	{
		public var data:Object;
		
		public function RealtimeObject(urlstr:URLStream) 
		{
			urlstr.addEventListener(ProgressEvent.PROGRESS, parseRead);
		}
		
		private function parseRead(e:ProgressEvent):void
		{
			trace("New data.");
			var message:String = e.target.readUTFBytes(e.target.bytesAvailable);
			if (message.indexOf("event: put") != -1)
			{
				var json:String = message.substr(message.indexOf("\ndata: ") + 7);
				trace("json to parse||" + json);
				var parsedReturn:Object = JSON.parse(json);
				
				var newObject:Object;
				
				if (parsedReturn.path == "/")
				{
					newObject = parsedReturn.data;
				}
				else
				{
					var pathRoute:Array = (parsedReturn.path as String).split("/");
					
					for each (var route:String in pathRoute)
					{
						newObject[route] = "hold";
						newObject = newObject[route];
					}
					
					newObject = parsedReturn.data;
				}
			}
			
			trace("New object made.");
			trace(JSON.stringify(newObject));
		}
		
		private function merge( obj0:Object, obj1:Object ):Object
		{
			var obj:Object = { };
			for( var p:String in obj0 )
			{
				obj[ p ] = ( obj1[ p ] != null ) ? obj1[ p ] : obj0[ p ];
				trace( p, ' : obj0', obj0[ p ], 'obj1', obj1[ p ], '-> new value = ', obj[ p ] );
			}
			return obj;
		}
		
	}

}