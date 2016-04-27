package Trolling.Component.Animation
{
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	import Trolling.Component.ComponentType;
	import Trolling.Component.DisplayComponent;
	import Trolling.Object.DisplayObject;

	public class Animator extends DisplayComponent
	{
		private const TAG:String = "[Animator]";
		private const NONE:String = "none";
		
		private var _states:Dictionary; // key: Name, value: State
		private var _currentState:String; // Name
		private var _isPlaying:Boolean;
		
		public function Animator(name:String, parent:DisplayObject)
		{
			super(ComponentType.ANIMATOR, name, parent);
			
			_currentState = NONE;
			_isPlaying = false;
		}
				
		public override function dispose():void
		{
			if (_states)
			{
				for (var key:String in _states)
				{
					State(_states[key]).dispose();
					_states[key] = null;
				}
			}
			_states = null;
			
			_currentState = null;
			_isPlaying = false;

			//removeEventListener(TouchEvent.ENDED, onTouch);
			
			super.dispose();
		}
		
		public override function getRenderingResource():BitmapData
		{
			// to do 
			
			
			return null;
		}
		
		public function play():void
		{
			if (!_states || _currentState == NONE)
			{
				return;
			}
			
			_isPlaying = true;
			State(_states[_currentState]).play();
		}
		
		public function stop():void
		{
			if (!_states || _currentState == NONE)
			{
				return;
			}
			
			_isPlaying = false;
			State(_states[_currentState]).stop();
		}
				
		public function addState(key:String, name:String):State
		{
			if (!name || name == "")
			{
				return null;
			}
			
			var isFirst:Boolean = false;
			if (!_states)
			{
				_states = new Dictionary();
				isFirst = true;
			}
			
			if (_states[key])
			{
				return null;
			}
			
			var state:State = new State(name);
			_states[key] = state;
			
			if (isFirst)
			{
				_currentState = key;
				//addEventListener(TouchEvent.ENDED, onTouch);
			}
			
			return state;
		}
		
		public function removeState(name:String):void
		{
			if (!name || name == "" || !_states)
			{
				return;
			}
			
			var key:String = isState(name);
			if (key == NONE)
			{
				return;
			}
			
			State(_states[key]).dispose();
			_states[key] = null;
			delete _states[key];
			
			_currentState = NONE;
			
			trace(TAG + " State 삭제가 완료되었습니다. State를 추가하거나 현재 State를 지정해주세요.");
		}
		
		public function get currentState():String
		{
			return _currentState;	
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
//		private function onTouch(event:TouchEvent):void
//		{
//			// Get key
//			
//			if (isKey(key))
//			{
//				transition(key);			
//			}
//		}
		
		private function isKey(input:String):Boolean
		{
			if (!_states)
			{
				return false;	
			}
			
			var result:Boolean = false;
			
			for (var key:String in _states)
			{
				if (key == input)
				{
					result = true;
					break;
				}
			}
			
			return result;
		}
		
		private function isState(input:String):String
		{
			if (!_states)
			{
				return NONE;	
			}
			
			for (var key:String in _states)
			{
				var state:State = _states[key];
				if (state.name == input)
				{
					return key;
				}
			}
			
			return NONE;
		}
		
		private function transition(key:String):void
		{
			if (!_states || _currentState == NONE)
			{
				return;
			}
				
			if (_isPlaying)
			{
				State(_states[_currentState]).stop();
				
				_currentState = key;
				
				State(_states[key]).play();
			}
		}
	}
}