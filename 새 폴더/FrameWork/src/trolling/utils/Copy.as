package trolling.utils
{
	import flash.utils.ByteArray;

	public class Copy
	{
		public function Copy()
		{
		}
		
		public static function clone(source:Object):*
		{
			var result:ByteArray = new ByteArray();
			result.writeObject(source);
			result.position = 0;
			return (result.readObject());
		}
	}
}