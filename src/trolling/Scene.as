package Trolling
{
	import Trolling.Object.DisplayObject;
	import Trolling.Rendering.Painter;

	public class Scene
	{
		private var _name:String;
		private var _children:Vector.<DisplayObject>;
		private var _isActive:Boolean;
		
		public function Scene(name:String)
		{
			_name = name;
		}
		
		public function dispose():void
		{
			
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
			
			// to do
		}
		
		public function activate():void
		{
			// to do
			
			
			_isActive = true;
		}
		
		public function deactivate():void
		{
			// to do
			
			
			_isActive = false;
		}
		
		public function get type():String
		{
			return _name;
		}
		
		public function get isActive():Boolean
		{
			return _isActive;
		}
	}
}