package Object
{
	import flash.utils.Dictionary;

	public class DisplayObject
	{
		private var _components:Dictionary;
		
		public function DisplayObject()
		{
			_components = new Dictionary();
		}
		
		public function addComponent(component:Property):void
		{
			if(_components[component.type] == null)
				_components[component.type] = new Vector.<Property>();
			
			_components[component.type].insertAt(_components[component.type].length, component);
		}
	}
}