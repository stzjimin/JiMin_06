package Trolling.component.control
{
	import flash.utils.Dictionary;
	
	import Trolling.Object.DisplayObject;
	import Trolling.component.Component;
	import Trolling.component.ComponentType;

	public class Controller extends Component
	{
		public const PLAYER:String = "player";
		public const AI:String = "ai";
		
		private const TAG:String = "[Controller]";
				
		private var _id:String;
		private var _movements:Dictionary; // key: KeyCode, value: State 
		
		public function Controller(name:String, parent:DisplayObject, id:String)
		{
			super(ComponentType.CONTROLLER, name, parent);
			
			_id = id;
		}
	}
}