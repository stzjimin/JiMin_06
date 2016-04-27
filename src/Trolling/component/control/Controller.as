package Trolling.Component.Control
{
	import flash.utils.Dictionary;
	
	import Trolling.Object.DisplayObject;
	import Trolling.Component.Component;
	import Trolling.Component.ComponentType;

	public class Controller extends Component
	{
		public static const PLAYER:String = "player";
		public static const AI:String = "ai";
		
		private const TAG:String = "[Controller]";
				
		private var _id:String;
		private var _movements:Dictionary; 
		
		public function Controller(name:String, parent:DisplayObject, id:String)
		{
			super(ComponentType.CONTROLLER, name, parent);
			
			_id = id;
		}
	}
}