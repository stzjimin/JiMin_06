package trolling.component.animation
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.event.TrollingEvent;
	import trolling.rendering.Texture;

	public class Animator extends DisplayComponent
	{
		private const TAG:String = "[Animator]";
		private const NONE:String = "none";
		
		private var _states:Dictionary; // key: String(Name), value: State
		private var _currentState:String; // State name
		
		public function Animator()
		{
			super(ComponentType.ANIMATOR);
			
			_currentState = NONE;
			
			addEventListener(TrollingEvent.ENTER_FRAME, onNextFrame);
			addEventListener(TrollingEvent.START_SCENE, onStartScene);
			addEventListener(TrollingEvent.END_SCENE, onEndScene);
		}
			
		public override function dispose():void
		{
			this.isActive = false;
			
			if (_states)
			{
				for (var key:String in _states)
				{
					var state:State = _states[key];
					state.dispose();
					state = null;
				}
			}
			_states = null;
			_currentState = null;
			
			super.dispose();
		}
		
		/**
		 * Animator의 활성화 여부를 제어합니다. 현재 State와 EventListener에 대한 처리를 포함합니다. 
		 * @param value 활성화 여부입니다.
		 * 
		 */
		public override function set isActive(value:Boolean):void
		{
			if (value)
			{
				if (!_isActive)
				{
					if (!_states)
					{
						return;
					}
					
					var state:State = _states[_currentState];
					state.play();
					
					addEventListener(TrollingEvent.ENTER_FRAME, onNextFrame);
					addEventListener(TrollingEvent.START_SCENE, onStartScene);
					addEventListener(TrollingEvent.END_SCENE, onEndScene);
				}
			}
			else
			{
				if (_isActive)
				{
					state = _states[_currentState];
					state.stop();
					
					removeEventListener(TrollingEvent.ENTER_FRAME, onNextFrame);
					removeEventListener(TrollingEvent.START_SCENE, onStartScene);
					removeEventListener(TrollingEvent.END_SCENE, onEndScene);
				}
			}

			_isActive = value;
		}
		
		/**
		 * 현재 프레임에 Render해야 하는 Texture를 반환합니다. 
		 * @return Animator가 비활성화 상태이거나 지정된 현재 State가 없을 경우 null을 반환합니다.
		 * 
		 */
		public override function getRenderingResource():Texture
		{
			if (!_isActive || !_states || _currentState == NONE)
			{
				if (!_isActive)
					trace(TAG + " getRenderingResource : Animator is inactive now.");
				else if (!_states)
					trace(TAG + " getRenderingResource : No State.");
				else if (_currentState == NONE)
					trace(TAG + " getRenderingResource : No current State.");
				
				return null;
			}
			
			var state:State = _states[_currentState];
			
			return state.getCurrentFrame();
		}
		
		/**
		 * Animator가 활성화 상태이며 지정된 현재 State가 있을 경우 해당 State에게 Event.ENTER_FRAME을 dispatch합니다. 
		 * @param event TrollingEvent.ENTER_FRAME
		 * 
		 */
		protected override function onNextFrame(event:TrollingEvent):void
		{
			if (_isActive && _states && _currentState != NONE)
			{
				var state:State = _states[_currentState];
				state.dispatchEvent(new TrollingEvent(event.type));
//				state.dispatchEvent(event);
			}
		}
		
		/**
		 * Animator가 속한 Scene이 활성화될 경우 이벤트를 수신하여 자기 자신을 활성화합니다. 
		 * @param event TrollingEvent.ACTIVATE
		 * 
		 */
		protected override function onStartScene(event:TrollingEvent):void
		{
			this.isActive = true;
		}
		
		/**
		 * Animator가 속한 Scene이 비활성화될 경우 이벤트를 수신하여 자기 자신을 비활성화합니다.
		 * @param event event TrollingEvent.DEACTIVATE
		 * 
		 */
		protected override function onEndScene(event:TrollingEvent):void
		{
			this.isActive = false;
		}
				
		/**
		 * State를 추가합니다. 최초로 추가하는 State일 경우 현재 State로 지정하고 play합니다.
		 * @param state
		 * 
		 */
		public function addState(state:State):void
		{
			if (!state)
			{
				trace(TAG + " addState : No state.");
				return;
			}
			
			if (_states && _states[state.name])
			{
				trace(TAG + " addState : Animator already has the state of same name.");
				return;
			}
			
			var isFirst:Boolean = false;
			if (!_states)
			{
				_states = new Dictionary();
				isFirst = true;
			}
			
			if (isFirst)
			{
				_currentState = state.name;
				state.play();
			}
			
			state.onEnd = transition;
			_states[state.name] = state;
		}
		
		/**
		 * 해당 이름의 State를 삭제합니다. 성공적으로 삭제가 이루어질 경우 현재 State가 NONE이 되므로, 이후 애니메이션을 재생할 때 transition을 통해 현재 State를 지정해야 합니다.
		 * @param stateName 삭제하고자 하는 State의 이름입니다.
		 * 
		 */
		public function removeState(stateName:String):void
		{
			if (_isActive || !stateName || !_states || !_states[stateName])
			{
				return;
			}

			var state:State = _states[stateName];
			state.dispose();
			state = null;
			delete _states[stateName];
			
			_currentState = NONE;
		}
		
		/**
		 * 해당 이름의 State을 반환합니다. 
		 * @param name 반환받고자 하는 State의 이름입니다. 
		 * @return 해당 이름을 가진 State입니다. 대상이 없을 경우 null을 반환합니다.
		 * 
		 */
		public function getState(name:String):State
		{
			if (!_states)
			{
				return null;	
			}
			
			for (var key:String in _states)
			{
				var state:State = _states[key];
				if (state.name == name)
				{
					return state;
				}
			}
			
			return null;
		}
		
		/**
		 * 해당 이름의 State를 교체합니다.
		 * @param name 교체하고자 하는 State의 이름입니다.
		 * @param editedState 새롭게 등록할 State입니다.
		 * 
		 */
		public function setState(name:String, editedState:State):void
		{
			if (_isActive || !_states)
			{
				return;	
			}
			
			for (var key:String in _states)
			{
				var state:State = _states[key];
				if (state.name == name)
				{
					state = editedState;
					break;
				}
			}
		}
		
		/**
		 * 현재 State를 해당 이름의 State로 전환하고 play합니다. 
		 * @param nextStateName 새로이 전환하고자 하는 State의 이름입니다.
		 * 
		 */
		public function transition(nextStateName:String):void
		{
			if (!_isActive || !_states || !_states[nextStateName])
			{
				return;
			}
			
			if (_currentState != NONE)
			{
				var currState:State = _states[_currentState];
				currState.stop();
			}
			
			_currentState = nextStateName;
			var nextState:State = _states[_currentState];
			nextState.play();
		}
		
		/**
		 * 애니메이션을 일시정지 또는 일시정지를 해제합니다. 일시정지할 경우 현재 애니메이션 프레임을 계속적으로 표시합니다. 
		 * @param freeze 일시정지 여부입니다.
		 * 
		 */
		public function freeze(freeze:Boolean):void
		{
			if (!_isActive || !_states || _currentState == NONE)
			{
				return;
			}
			
			var currState:State = _states[_currentState];
			currState.freeze(freeze);
		}
		
		/**
		 * 현재 State의 이름입니다. 
		 * @return 
		 * 
		 */
		public function get currentState():String
		{
			return _currentState;	
		}
	}
}