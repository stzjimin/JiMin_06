package trolling.component
{
	import flash.events.EventDispatcher;
	
	import trolling.event.TrollingEvent;
	import trolling.object.GameObject;
	
	public class Component extends EventDispatcher
	{		
		private var _type:String;
		protected var _parent:GameObject;
		protected var _isActive:Boolean;
		
		public function Component(type:String)
		{
			_type = type;
			_isActive = true;
		}
		
		/**
		 *컴포넌트를 정지시킵니다. 
		 * 
		 */		
		public function dispose():void
		{
			_type = null;
			_isActive = false;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get parent():GameObject
		{
			return _parent;
		}
		
		public virtual function set parent(value:GameObject):void
		{
			_parent = value;
		}
		
		public function get isActive():Boolean
		{
			return _isActive;
		}
		
		public virtual function set isActive(value:Boolean):void
		{
			_isActive = value;
		}
		
		protected virtual function onNextFrame(event:TrollingEvent):void
		{
			// Empty
		}
		
		protected virtual function onStartScene(event:TrollingEvent):void
		{
			// Empty
		}
		
		protected virtual function onEndScene(event:TrollingEvent):void
		{
			// Empty
		}
	}
}