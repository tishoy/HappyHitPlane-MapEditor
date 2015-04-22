package 
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.registerClassAlias;
	/**
	 * 本地储存管理器
	 * @author 王润智
	 */
	public class LocalSaveManager
	{
		public static function saveInputDir(dirList:Array):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath("inputDir");
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeObject(dirList);
			stream.close();
		}
		
		public static function getInputDir():Array
		{
			var file:File = File.applicationStorageDirectory.resolvePath("inputDir");
			if (file.exists)
			{
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				var dir:Array = stream.readObject();
				stream.close();
			}
			return dir;
		}
		
		public static function saveOutputDir(dirList:Array):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath("outputDir");
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeObject(dirList);
			stream.close();
		}
		
		public static function getOutputDir():Array
		{
			var file:File = File.applicationStorageDirectory.resolvePath("outputDir");
			if (file.exists)
			{
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				var dir:Array = stream.readObject();
				stream.close();
			}
			return dir;
		}
		
		public static function saveURL(directory:String, URL:String):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath(URL);
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTF(directory);
			stream.close();
		}
		
		public static function getURL(URL:String):String
		{
			var file:File = File.applicationStorageDirectory.resolvePath(URL);
			if (file.exists)
			{
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				var configCFG:String;
				while (stream.bytesAvailable)
				{
					configCFG = stream.readUTF();
				}
				stream.close();
				return configCFG;
			}
			return null;
		}
	}
}