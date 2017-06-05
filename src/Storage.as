package FirebaseREST.src 
{
	import FirebaseREST.src.events.StorageEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Samuel Walker
	 */
	public class Storage extends EventDispatcher
	{
		private var projectID:String;
		private var authToken:String;
		
		private var storageURL:String;
		
		public function Storage(projectID:String, authToken:String) 
		{
			this.projectID = projectID;
			this.authToken = authToken;
			
			storageURL = "https://firebasestorage.googleapis.com/v0/b/" + projectID + ".appspot.com/o/";
		}
		
		public function authChange(auth:String):void
		{
			authToken = auth;
		}
		
		//Populated file reference.
		public function upload(fileReference:FileReference, contentType:String, location:String, auth:Boolean = false);
		{
			var rq:URLRequest = new URLRequest(storageURL + location + fileReference.name);
			rq.method = URLRequest.POST;
			rq.data = fileReference.data;
			rq.contentType = contentType;
			
			if (auth)
			{
				var header:URLRequestHeader = new URLRequestHeader("Authorization", "Bearer " + authToken);
				rq.requestHeaders.push(header);
			}
			
			var l:URLLoader = new URLLoader();
			l.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			l.addEventListener(Event.COMPLETE, uploadComplete);
			l.load(rq);
		}
		
		//Full path is a full path and a name. Ex: path/to/file.extension
		public function deleteFile(fullPath:String, auth:Boolean = false)
		{
			var header:URLRequestHeader = new URLRequestHeader("X-HTTP-Method-Override", "DELETE");
			
			var rq:URLRequest = new URLRequest(storageURL + fullPath);
				rq.method = URLRequestMethod.POST;
				rq.requestHeaders.push(header);
			if (auth)
			{
				var header2:URLRequestHeader = new URLRequestHeader("Authorization", "Bearer " + authToken);
				rq.requestHeaders.push(header2);
			}
			
			var l:URLLoader = new URLLoader();
				l.addEventListener(Event.COMPLETE, deleteComplete);
				l.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
				l.load(rq);
		}
		
		//Attach event listeners to return value for progress and complete events.
		private function downloadFile(fullPath:String, downloadTokens:String=null):URLLoader
		{
			var rq:URLRequest = new URLRequest(storageURL + fullPath + "?alt=media");
			if (downloadTokens != null)
			{
				rq.url += "&token=" + downloadTokens;
			}
			var l:URLLoader = new URLLoader();
			l.dataFormat = URLLoaderDataFormat.BINARY;
			l.load(rq);
			
			return l;
		}
		
		private function deleteComplete(e:Event):void
		{
			dispatchEvent(new StorageEvent(StorageEvent.DELETE_COMPLETE));
		}
		
		private function handleIOError(e:IOErrorEvent):void 
		{
			dispatchEvent(e);
		}
		
		private function uploadComplete(e:Event):void 
		{
			dispatchEvent(new StorageEvent(StorageEvent.UPLOAD_COMPLETE, JSON.parse(e.target.data)));
		}
		
	}

}