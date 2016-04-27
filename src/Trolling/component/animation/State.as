package Trolling.Component.Animation
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class State extends EventDispatcher
	{
		private var _name:String;
		private var _animation:Vector.<BitmapData>;
		private var _isPlaying:Boolean;
		
		public function State(name:String)
		{
			_name = name;
			_isPlaying = false;
			//addEventListener(Event.ENTER_FRAME, onEnterFrame); // !! nextFrame에서 작업할 것
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
			// Reset current frame
			
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
				// Render
				// Renderer에 전역적으로 접근이 가능한 구조인지? -> 아 니오. nextFrame 이벤트마다 그려야 하는 데이터를 바꿀 것.
			}
		}
	}
}