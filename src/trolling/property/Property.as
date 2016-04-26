package trolling.property
{
	import trolling.object.GameObject;

	public class Property
	{		
		private var _type:String;
		private var _name:String;
		private var _parent:GameObject;
		private var _isActive:Boolean;
				
		public function Property()
		{
			_name = null;
			_type = null;
			_parent = null;
			_isActive = true;
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
		
		public function set type(value:String):void
		{
			_type = value;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get parent():DisplayObject
		{
			return _parent;
		}
		
		public function set parent(value:DisplayObject):void
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