package net.sfxworks.firebaseREST 
{
	import flash.events.ProgressEvent;
	import flash.net.URLStream;
	import net.sfxworks.firebaseREST.events.DatabaseEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;

	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class Database extends EventDispatcher
	{
		private var projectID:String;
		private var authToken:String;
		private var databaseURL:String;
		
		public static const FIREBASE_SERVER_TIME:Object = {".sv": "timestamp"};
		private static const EVENT_IDENTIFIER:String = "event: ";
		private static const DATA_IDENTIFIER:String = "\ndata: ";
		
		private var urlStreams:Vector.<URLStream>;
		private var eventTypes:Vector.<String>;
		private var streamParts:Vector.<String>;
		private var nodePaths:Vector.<String>;
		
		private var partCounter:int = 0;
		
		public function Database(projectID:String)
		{
			this.projectID = projectID;
			databaseURL = "https://" + projectID + ".firebaseio.com/";
			
			urlStreams = new Vector.<URLStream>();
			streamParts = new Vector.<String>();
			eventTypes = new Vector.<String>();
			nodePaths = new Vector.<String>();
		}
		
		public function authChange(str:String):void
		{
			authToken = str;
		}
		
		public function read(node:String, auth:Boolean=false):void
		{
			var rq:URLRequest = new URLRequest(databaseURL + node + ".json");
			if (auth)
			{
				rq.url += "?auth=" + authToken;
			}
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataRead);
			l.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			
			l.load(rq);
		}
		
		public function once(node:String, callback:Function, auth:Boolean = false):void
		{
			function dataReadOnce(e:Event):void 
			{
				l.removeEventListener(Event.COMPLETE, dataReadOnce);
				l.removeEventListener(IOErrorEvent.IO_ERROR, handleIOError);
				callback(JSON.parse(e.target.data));
			}
			var rq:URLRequest = new URLRequest(databaseURL + node + ".json");
			if (auth)
			{
				rq.url += "?auth=" + authToken;
			}
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataReadOnce);
			l.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			
			l.load(rq);
			
			
		}
		
		
		
		public function write(node:String, data:Object, auth:Boolean = false):void
		{
			var rq:URLRequest = new URLRequest(databaseURL + node + ".json");
			rq.data = JSON.stringify(data);
			rq.method = URLRequestMethod.POST;
			
			if (auth)
			{
				rq.url += "?auth=" + authToken;
			}
			
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataSent);
			l.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			l.load(rq);
		}
		
		public function readRealTime(node:String, auth:Boolean = false):void
		{
			var header:URLRequestHeader = new URLRequestHeader("Accept", "text/event-stream");
			
			var rq:URLRequest = new URLRequest(databaseURL + node + ".json");
			rq.requestHeaders.push(header);
			
			if (auth)
			{
				rq.url += "?auth=" + authToken;
			}
			
			var uRLStream:URLStream = new URLStream();
			urlStreams.push(uRLStream);
			uRLStream.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			eventTypes.push("unknown");
			nodePaths.push(node);
			uRLStream.addEventListener(ProgressEvent.PROGRESS, handleURLStreamProgress);
			streamParts.push(new String());
			uRLStream.load(rq);
			
		}
		
		private function handleURLStreamProgress(e:ProgressEvent):void 
		{
			var streamPartIndex:int = urlStreams.indexOf(e.target);
			var urlStream:URLStream = urlStreams[streamPartIndex];
			var streamPart:String = streamParts[streamPartIndex];
			
			var currentString:String = e.target.readUTFBytes(e.target.bytesAvailable);
			//trace(currentString.substr(0, 20));
			if (currentString.substr(0, 7) == EVENT_IDENTIFIER)
			{
				var eventType:String = currentString.substr(7);
				eventType = eventType.split("\n")[0];
				
				switch(eventType)
				{
					case DatabaseEvent.REALTIME_PUT:
					case DatabaseEvent.REALTIME_PATCH:
						eventTypes[streamPartIndex] = eventType;
						currentString = currentString.split(DATA_IDENTIFIER)[1];
						break;
					case DatabaseEvent.REALTIME_KEEP_ALIVE:
					case DatabaseEvent.REALTIME_CANCEL:
					case DatabaseEvent.REALTIME_AUTH_REVOKED:
						dispatchEvent(new DatabaseEvent(eventType, null, nodePaths[streamPartIndex]));
						return;
				}
				
				
			}
			
			streamPart += currentString;
			streamParts[streamPartIndex] = streamPart;
			
			try
			{
				
				var jsonObject:Object = JSON.parse(streamPart);
				dispatchEvent(new DatabaseEvent(eventTypes[streamPartIndex], jsonObject.data, nodePaths[streamPartIndex] + String(jsonObject.path)));
				eventTypes[streamPartIndex] = "";
				streamParts[streamPartIndex] = "";
				
			}
			catch ( e:Error )
			{
				dispatchEvent(new DatabaseEvent(DatabaseEvent.REALTIME_PROGRESS, null, nodePaths[streamPartIndex]));
			}
		}
		
		public function update(node:String, data:Object, auth:Boolean = false):void
		{
		    var header:URLRequestHeader = new URLRequestHeader("X-HTTP-Method-Override", "PATCH");
			
			var rq:URLRequest = new URLRequest(databaseURL + node + ".json");
			rq.data = JSON.stringify(data);
			rq.method = URLRequestMethod.POST;
			rq.requestHeaders.push(header);
			
			if (auth)
			{
				rq.url += "?auth=" + authToken;
			}
			
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, updateComplete);
			l.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			l.load(rq);
		}
		
		public function deleteNode(node:String, auth:Boolean = true):void
		{
			var header:URLRequestHeader = new URLRequestHeader("X-HTTP-Method-Override", "DELETE");
			
			var rq:URLRequest = new URLRequest(databaseURL + node + ".json");
			rq.method = URLRequestMethod.POST;
			rq.requestHeaders.push(header);
			
			if (auth)
			{
				rq.url += "?auth=" + authToken;
			}
			
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, entryDeleted);
			l.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			l.load(rq);
			
		}
		
		private function entryDeleted(e:Event):void 
		{
			dispatchEvent(new DatabaseEvent(DatabaseEvent.DATA_DELETED));
		}
		
		private function updateComplete(e:Event):void 
		{
			dispatchEvent(new DatabaseEvent(DatabaseEvent.UPDATE_COMPLETE, JSON.parse(e.currentTarget.data)));
		}
		
		
		private function handleIOError(e:IOErrorEvent):void 
		{
			dispatchEvent(e);
		}
		
		private function dataRead(e:Event):void 
		{
			dispatchEvent(new DatabaseEvent(DatabaseEvent.DATA_READ, JSON.parse(e.currentTarget.data)));
		}
		
		private function dataSent(e:Event):void 
		{
			dispatchEvent(new DatabaseEvent(DatabaseEvent.DATA_WRITTEN, JSON.parse(e.currentTarget.data)));
		}
		
	}

}