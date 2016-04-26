package trolling.object
{
	import flash.utils.Dictionary;
	
	import trolling.property.Property;

	public class GameObject
	{
		private const TAG:String = "[GameObject]";
		
		private var _properties:Dictionary; // key: Property Type, value: Property
		
		public function GameObject()
		{
			_properties = new Dictionary();
		}
		
		public function addComponent(property:Property):void
		{
			if(_properties[property.type])
			{
				trace(TAG + " 해당 타입의 Property가 이미 존재합니다.");
				return;
			}
			
			_properties[property.type] = property;
		}
	}
}