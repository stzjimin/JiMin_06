package trolling.utils
{
	public class PivotType
	{
		private static const _CENTER:String = "center";
		private static const _TOP_LEFT:String = "topLeft";
		
		public function PivotType()
		{
		}
		
		public static function get TOP_LEFT():String
		{
			return _TOP_LEFT;
		}
		
		public static function get CENTER():String
		{
			return _CENTER;
		}
	}
}