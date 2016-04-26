package Trolling.property
{
	import flash.events.EventDispatcher;
	
	import Trolling.Object.GameObject;

	public class Property extends EventDispatcher
	{		
		private var _type:String;
		private var _name:String;
		private var _parent:GameObject;
		private var _isActive:Boolean;
				
		public function Property(type:String, name:String, parent:GameObject)
		{
			_type = type;
			_name = name;
			_parent = parent;
			_isActive = isActive;
		}
		
		public function dispose():void
		{
			_name = null;
			_type = null;
			_parent = null;
			_isActive = false;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get parent():GameObject
		{
			return _parent;
		}
		
		public function set parent(value:GameObject):void
		{
			_parent = value;
		}
		
		public function get isActive():Boolean
		{
			return _isActive;
		}
		
		public function set isActive(value:Boolean):void
		{
			_isActive = value;
		}
	}
}