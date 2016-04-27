package Trolling.property.animation
{
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	import Trolling.Object.DisplayObject;
	import Trolling.property.Property;
	import Trolling.property.PropertyType;

	public class Animator extends Property
	{
		private const TAG:String = "[Animator]";
		private const NONE:uint = 0;
		
		private var _states:Dictionary; // key: KeyCode, value: State
		private var _currentState:uint; // KeyCode
		private var _isPlaying:Boolean;
		
		public function Animator(name:String, parent:DisplayObject)
		{
			super(PropertyType.ANIMATOR, name, parent);
			
			_currentState = NONE;
			_isPlaying = false;
		}
				
		public override function dispose():void
		{
			if (_states)
			{
				for (var key:uint in _states)
				{
					State(_states[key]).dispose();
					_states[key] = null;
				}
			}
			_states = null;
			
			_currentState = NONE;
			_isPlaying = false;

			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			super.dispose();
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
				
		public function addState(key:uint, name:String):State
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
				addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			}
			
			return state;
		}
		
		public function removeState(name:String):void
		{
			if (!name || name == "" || !_states)
			{
				return;
			}
			
			var key:uint = isState(name);
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
			if (!_states || _currentState == NONE)
			{
				return null;
			}
			
			return State(_states[_currentState]).name;	
		}
		
		public function set currentState(name:String):void
		{
			var key:uint = isState(name);
			if (key != NONE)
			{
				transition(key);
			}
		}
		
		public function get idPlaying():Boolean
		{
			return _isPlaying;
		}
		
		private function onKeyDown(event:KeyboardEvent):void // 혜윤: 현재 키보드 입력에 의해서만 애니메이션이 이루어지도록 되어 있어요
		{
			var key:uint = event.keyCode;
			
			if (isKey(key))
			{
				transition(key);			
			}
		}
		
		private function isKey(input:uint):Boolean
		{
			if (!_states)
			{
				return false;	
			}
			
			var result:Boolean = false;
			
			for (var key:uint in _states)
			{
				if (key == input)
				{
					result = true;
					break;
				}
			}
			
			return result;
		}
		
		private function isState(input:String):uint
		{
			if (!_states)
			{
				return NONE;	
			}
			
			for (var key:uint in _states)
			{
				var state:State = _states[key];
				if (state.name == input)
				{
					return key;
				}
			}
			
			return NONE;
		}
		
		private function transition(key:uint):void
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