package trolling.property.control
{
	import trolling.object.GameObject;
	import trolling.property.Property;
	import trolling.property.PropertyType;

	public class Controller extends Property
	{
		public function Controller(name:String, parent:GameObject)
		{
			super(PropertyType.CONTROLLER, name, parent);
		}
	}
}