package Trolling.Component.Animation
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class State extends EventDispatcher
	{
		private var _name:String;
		private var _animation:Vector.<BitmapData>;
		private var _currentIndex:int;
		private var _playSpeed:uint; // 다음 애니메이션 인덱스로 업데이트 하기까지의 프레임 수
		private var _frameCounter:uint;
		private var _isPlaying:Boolean;
		
		public function State(name:String)
		{
			_name = name;
			_currentIndex = -1;
			_playSpeed = 0;
			_frameCounter = 0;
			_isPlaying = false;
		}
		
		public function dispose():void
		{
			_name = null;
			
			if (_animation && _animation.length > 0)
			{
				for (var i:int = 0; i < _animation.length; i++)
				{
					//_animation[i].dispose();
					_animation[i] = null;
				}
			}
			_animation = null;
			
			_currentIndex = -1;
			_playSpeed = 0;
			_frameCounter = 0;
			_isPlaying = false;
		}
		
		public function play():void
		{
			if (!_animation)
			{
				return;
			}
			
			_currentIndex = 0;
			
			if (_playSpeed == 0) // playSpeed가 설정되어있지 않으면 1로 보정
			{
				_playSpeed = 1;
			}
			
			_isPlaying = true;			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function stop():void
		{
			_currentIndex = -1;
			_isPlaying = false;
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function addFrame(frame:BitmapData):void
		{
			if (!frame)
			{
				return;
			}
			
			if (!_animation)
			{
				_animation = new Vector.<BitmapData>();
			}
			_animation.push(frame);
		}
		
		public function removeFrame(index:int):void
		{
			if (!_animation || index < 0 || index >= _animation.length || _isPlaying)
			{
				return;
			}
			
			//_animation[index].dispose();
			_animation[index] = null;
			_animation.removeAt(index);
		}
		
		public function get name():String
		{
			return _name;	
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get currentIndex():int
		{
			return _currentIndex;	
		}
		
		public function get playSpeed():uint
		{
			return _playSpeed;	
		}
		
		public function set playSpeed(value:uint):void
		{
			if (value <= 0)
			{
				value = 1;
			}
			_playSpeed = value;
		}

		public function get isPlaying():Boolean
		{
			return _isPlaying;	
		}
		
		private function onEnterFrame(event:Event):void
		{
			if (!_isPlaying)
			{
				return;
			}
			
			_frameCounter++;
			
			if (_frameCounter == _playSpeed)
			{
				_currentIndex++;
				
				if (_currentIndex >= _animation.length)
				{
					_currentIndex = 0;
				}
				
				_frameCounter = 0;
			}
		}
	}
}