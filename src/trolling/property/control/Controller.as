package Trolling.property.control
{
	import flash.utils.Dictionary;
	
	import Trolling.Object.GameObject;
	import Trolling.property.Property;
	import Trolling.property.PropertyType;

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