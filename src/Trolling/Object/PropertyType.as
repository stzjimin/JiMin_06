package Trolling.Object
{
	public class PropertyType
	{
		private static const _Event:String = "event";
		private static const _Controll:String = "controll";
		private static const _Image:String = "image";
		private static const _Sound:String = "sound";
		
		public function PropertyType()
		{
		}

		public static function get Sound():String
		{
			return _Sound;
		}

		public static function get Image():String
		{
			return _Image;
		}

		public static function get Controll():String
		{
			return _Controll;
		}

		public static function get Event():String
		{
			return _Event;
		}

	}
}