package trolling.property.control
{
	import flash.utils.Dictionary;
	
	import trolling.object.GameObject;
	import trolling.property.Property;
	import trolling.property.PropertyType;

	public class Controller extends Property
	{
		public const PLAYER:String = "player";
		public const AI:String = "ai";
		
		private const TAG:String = "[Controller]";
				
		private var _id:String;
		private var _movements:Dictionary; // key: KeyCode, value: State 
		
		public function Controller(name:String, parent:GameObject, id:String)
		{
			super(PropertyType.CONTROLLER, name, parent);
			
			_id = id;
		}
	}
}