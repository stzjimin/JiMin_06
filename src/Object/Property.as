package Object
{
	public class Property
	{
		private var _type:String;
		
		public function Property()
		{
			
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function set type(value:String):void
		{
			_type = value;
		}
	}
}