package trolling.property.animation
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class State extends EventDispatcher
	{
		private var _name:String;
		// 이미지
		private var _isPlaying:Boolean;
		
		public function State(name:String)
		{
			_name = name;
			_isPlaying = false;
			//addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function dispose():void
		{
			
		}
		
		public function play():void
		{
			_isPlaying = true;
		}
		
		public function stop():void
		{
			_isPlaying = false;
		}
		
		public function get name():String
		{
			return _name;	
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		private function onEnterFrame(event:Event):void
		{
			if (_isPlaying)
			{
				// to do
				
			}
		}
	}
}