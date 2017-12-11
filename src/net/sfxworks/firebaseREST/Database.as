package net.sfxworks.firebaseREST 
{
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.URLStream;
	import flash.utils.Timer;
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
		private var retrys:Vector.<int>;
		private var numberOfRetryAttempts:Vector.<int>;
		private var timeoutTimers:Vector.<Timer>;
		
		private var partCounter:int = 0;
		
		public function Database(projectID:String)
		{
			this.projectID = projectID;
			databaseURL = "https://" + projectID + ".firebaseio.com/";
			
			urlStreams = new Vector.<URLStream>();
			streamParts = new Vector.<String>();
			eventTypes = new Vector.<String>();
			nodePaths = new Vector.<String>();
			retrys = new Vector.<int>();
			numberOfRetryAttempts = new Vector.<int>();
			timeoutTimers = new Vector.<Timer>();
		}
		
		public function authChange(str:String):void
		{
			authToken = str;
		}
		
		public function read(node:String, auth:Boolean=false):void
		{
			var rq:URLRequest = new URLRequest(databaseURL + node + ".json");
			rq.useCache = false;
			rq.cacheResponse = false;
			if (auth)
			{
				rq.url += "?auth=" + authToken;
			}
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataRead);
			l.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			
			l.load(rq);
		}
		
		public function once(node:String, callback:Function, auth:Boolean = false, shallow:Boolean=false):void
		{
			function dataReadOnce(e:Event):void 
			{
				l.removeEventListener(Event.COMPLETE, dataReadOnce);
				l.removeEventListener(IOErrorEvent.IO_ERROR, handleIOError);
				callback(JSON.parse(e.target.data));
			}
			var rq:URLRequest = new URLRequest(databaseURL + node + ".json");
			rq.useCache = false;
			rq.cacheResponse = false;
			if (auth)
			{
				rq.url += "?auth=" + authToken + "&shallow=" + shallow.toString();
			}
			else
			{
				rq.url += "?shallow=" + shallow.toString();
			}
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataReadOnce);
			l.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			
			l.load(rq);
			
			
		}
		
		
		
		public function write(node:String, data:Object, auth:Boolean = false):void
		{
			var rq:URLRequest = new URLRequest(databaseURL + node + ".json");
			rq.useCache = false;
			rq.cacheResponse = false;
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
		
		public function readRealTime(node:String, auth:Boolean = false, retryAttempts:int=int.MAX_VALUE):void
		{
			var header:URLRequestHeader = new URLRequestHeader("Accept", "text/event-stream");
			
			var rq:URLRequest = new URLRequest(databaseURL + node + ".json");
			rq.requestHeaders.push(header);
			rq.useCache = false;
			rq.cacheResponse = false;
			
			if (auth)
			{
				rq.url += "?auth=" + authToken;
			}
			
			var uRLStream:URLStream;
			
			
			if (nodePaths.indexOf(node) == -1)
			{
				uRLStream = new URLStream();
				uRLStream.addEventListener(IOErrorEvent.IO_ERROR, handleURLStreamIOError);
				uRLStream.addEventListener(ProgressEvent.PROGRESS, handleURLStreamProgress);
				var timeoutTimer:Timer = new Timer(30000, 1);
				timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleURLStreamTimeout);
				timeoutTimer.start();
				timeoutTimers.push(timeoutTimer);
				urlStreams.push(uRLStream);
				retrys.push(retryAttempts);
				numberOfRetryAttempts.push(0);
				eventTypes.push("unknown");
				nodePaths.push(node);
				streamParts.push("");
			}
			else
			{
				var streamPartIndex:int = nodePaths.indexOf(node);
				numberOfRetryAttempts[streamPartIndex]++;
				uRLStream = urlStreams[streamPartIndex];
				timeoutTimers[streamPartIndex].reset();
				timeoutTimers[streamPartIndex].start();
				eventTypes[streamPartIndex] = "";
				streamParts[streamPartIndex] = "";
			}
			
			uRLStream.load(rq);
		}
		
		private function handleURLStreamTimeout(e:TimerEvent):void 
		{
			trace("URLStream Timeout");
			
			var streamPartIndex:int = timeoutTimers.indexOf(e.currentTarget);
			attemptReconnect(streamPartIndex);
		}
		
		
		private function handleURLStreamIOError(e:IOErrorEvent):void 
		{
			dispatchEvent(e);
			dispatchEvent(new DatabaseEvent(DatabaseEvent.REALTIME_FAILURE, null, nodePaths[streamPartIndex]))
			
			trace("URLStream io error.");
			var streamPartIndex:int = urlStreams.indexOf(e.currentTarget);
			attemptReconnect(streamPartIndex);
			
		}
		
		private function attemptReconnect(streamPartIndex:int):void
		{
			var retryMax:int = retrys[streamPartIndex];
			var numberOfAttempts:int = numberOfRetryAttempts[streamPartIndex];
			
			if (retryMax > numberOfAttempts)
			{
				trace("Retrying..");
				//Retry again.
				readRealTime(nodePaths[streamPartIndex], true, retrys[streamPartIndex]);
			}
			else
			{
				trace("Remvong stream.");
				//Remove stream.
				timeoutTimers[streamPartIndex].stop();
				timeoutTimers[streamPartIndex].removeEventListener(TimerEvent.TIMER_COMPLETE, handleURLStreamTimeout);
				urlStreams[streamPartIndex].removeEventListener(IOErrorEvent.IO_ERROR, handleURLStreamIOError);
				urlStreams[streamPartIndex].close();
				
				dispatchEvent(new DatabaseEvent(DatabaseEvent.REALTIME_FAILURE, null, nodePaths[streamPartIndex]))
				
				urlStreams[streamPartIndex] = null;
				eventTypes[streamPartIndex] = null;
				streamParts[streamPartIndex] = null;
				nodePaths[streamPartIndex] = null;
				retrys[streamPartIndex] = null;
				numberOfRetryAttempts[streamPartIndex] = null;
				timeoutTimers[streamPartIndex] = null;
			}
		}
		
		private function handleURLStreamProgress(e:ProgressEvent):void 
		{
			var streamPartIndex:int = urlStreams.indexOf(e.target);
			var urlStream:URLStream = urlStreams[streamPartIndex];
			var streamPart:String = streamParts[streamPartIndex];
			numberOfRetryAttempts[streamPartIndex] = 0;
			timeoutTimers[streamPartIndex].reset();
			timeoutTimers[streamPartIndex].start();
			
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
			rq.useCache = false;
			rq.cacheResponse = false;
			
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
			rq.useCache = false;
			rq.cacheResponse = false;
			
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