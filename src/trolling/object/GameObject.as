package trolling.object
{
	import flash.utils.Dictionary;
	
	import trolling.property.Property;

	public class GameObject
	{
		
		private var _properties:Dictionary; // key: Property Type, value: Property
		
		public function GameObject()
		{
			_properties = new Dictionary();
		}
		
		public function addComponent(property:Property):void
		{
			if(_propertys[property.type] == null)
				_propertys[property.type] = new Vector.<Property>();

			_propertys[property.type].insertAt(_propertys[property.type].length, property);
		}
			
		}
	}
}