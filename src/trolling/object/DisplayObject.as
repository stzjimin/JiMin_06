package trolling.object
{
	import flash.utils.Dictionary;
	import trolling.property.Property;
	import trolling.Painter;

	public class DisplayObject
	{
		private var _propertys:Dictionary;
		private var _children:Vector.<DisplayObject>;
		
		public function DisplayObject()
		{
			_propertys = new Dictionary();
		}
		
		public function addComponent(property:Property):void
		{
			if(_propertys[property.type] == null)
				_propertys[property.type] = new Vector.<Property>();
			
			_propertys[property.type].insertAt(_propertys[property.type].length, property);
		}
		
		public function addChild(child:DisplayObject):void
		{
			if(_children == null)
				_children = new Vector.<DisplayObject>();
			_children.insertAt(_children.length, child);
		}
		
		public function render(painter:Painter):void
		{
			var numChildren:int = _children.length;
			
		}
	}
}