package net.sfxworks.firebaseREST 
{
	import net.sfxworks.firebaseREST.events.DatabaseEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import mx.events.Request;
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
		
		
		public function Database(projectID:String)
		{
			this.projectID = projectID;
			databaseURL = "https://" + projectID + ".firebaseio.com/";
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
		
		public function update(node:String, data:Object, auth:Boolean = false):void
		{
		    var header:URLRequestHeader = new URLRequestHeader("X-HTTP-Method-Override", "PATCH");
			
			var rq:URLRequest = new URLRequest(databaseURL + node + ".json");
			rq.data = JSON.stringify(data);
			rq.method = URLRequestMethod.POST;
			rq.requestHeaders.push(header);
			
			var l:URLLoader = new URLLoader(rq);
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