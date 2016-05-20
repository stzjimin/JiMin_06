package trolling.component.animation
{
	import flash.events.EventDispatcher;
	
	import trolling.event.TrollingEvent;
	import trolling.rendering.Texture;
	
	public class State extends EventDispatcher
	{
		private const TAG:String = "[State]";
		
		private var _name:String;
		private var _animation:Vector.<Texture>;
		private var _currentIndex:int;
		
		private var _interval:uint;
		private var _frameCounter:uint;
		
		private var _isLoop:Boolean;
		private var _nextState:String;
		private var _onEnd:Function;
		
		private var _isPlaying:Boolean;
		private var _isFrozen:Boolean;
		
		public function State(name:String)
		{
			_name = name;
			_currentIndex = -1;
			_interval = 0;
			_frameCounter = 0;
			_isLoop = true;
			_nextState = null;
			_isPlaying = false;
			_isFrozen = false;
		}
		
		public function dispose():void
		{
			stop();
			
			_name = null;
			
			if (_animation && _animation.length > 0)
			{
				for (var i:int = 0; i < _animation.length; i++)
				{
					_animation[i] = null;
				}
			}
			_animation = null;
			
			_currentIndex = -1;
			_interval = 0;
			_frameCounter = 0;
			_isLoop = false;
			_nextState = null;
		}
		
		/**
		 * 애니메이션을 재생합니다. 재생은 항상 첫 번째 프레임부터 순차적으로 이루어집니다.
		 * 
		 */
		public function play():void
		{
			if (!_isPlaying)
			{
				if (!_animation)
				{
					return;
				}
				
				_currentIndex = 0;
				
				if (_interval == 0) // [혜윤] interval이 설정되어있지 않으면 1로 보정
				{
					_interval = 1;
				}
				
				_isPlaying = true;			
				addEventListener(TrollingEvent.ENTER_FRAME, onNextFrame);
			}
		}
		
		/**
		 * 애니메이션을 정지합니다. 
		 * 
		 */
		public function stop():void
		{
			if (_isPlaying)
			{
				_currentIndex = -1;
				_frameCounter = 0;
				_isPlaying = false;
				_isFrozen = false;
				removeEventListener(TrollingEvent.ENTER_FRAME, onNextFrame);
			}
		}
		
		/**
		 * 애니메이션을 일시정지 또는 일시정지를 해제합니다. 일시정지할 경우 현재 애니메이션 프레임을 계속적으로 표시합니다. 
		 * @param freeze 일시정지 여부입니다.
		 * 
		 */
		public function freeze(freeze:Boolean):void
		{
			if (!_isPlaying)
			{
				return;
			}
			
			_isFrozen = freeze;
		}
		
		/**
		 * 애니메이션 프레임(trolling.rendering.Texture)을 추가합니다. 애니메이션이 이루어져야하는 순서대로 추가할 필요가 있습니다.
		 * @param frame
		 * 
		 */
		public function addFrame(frame:Texture):void
		{
			if (!frame)
			{
				trace(TAG + " addFrame : No \'resource\'.");
				return;
			}
			
			if (!_animation)
			{
				_animation = new Vector.<Texture>();
			}
			_animation.push(frame);
		}
		
		/**
		 * 지정한  순서의 애니메이션 프레임을 제거합니다. 현재 재생 중일 경우 제거가 되지 않습니다.  
		 * @param index 제거하고자 하는 프레임의 인덱스입니다.
		 * 
		 */
		public function removeFrame(index:int):void
		{
			if (!_animation || index < 0 || index >= _animation.length || _isPlaying)
			{
				return;
			}
			
			_animation[index].dispose();
			_animation[index] = null;
			_animation.removeAt(index);
		}
		
		/**
		 * 현재 프레임(trolling.rendering.Texture)을 반환합니다. 
		 * @return 현재 프레임입니다.
		 * 
		 */
		public function getCurrentFrame():Texture
		{
			if (!_animation || _currentIndex < 0 || !_isPlaying)
			{
				if (!_animation || _currentIndex < 0)
					trace(TAG + " getCurrentFrame : No animating resource.");
				else if (!_isPlaying)
					trace(TAG + " getCurrentFrame : Animation is not playing.");
				
				return null;
			}
			else
			{
				return _animation[_currentIndex];
			}
		}
		
		public function get name():String
		{
			return _name;	
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		/**
		 * 현재 애니메이션 프레임의 인덱스입니다. 
		 * @return 
		 * 
		 */
		public function get currentIndex():int
		{
			return _currentIndex;	
		}
		
		/**
		 * 다음 애니메이션 인덱스로 업데이트 하기까지의 프레임 수입니다. 최소값은 1입니다.
		 * @param value
		 * 
		 */
		public function get interval():uint
		{
			return _interval;	
		}
		
		/**
		 * 다음 애니메이션 인덱스로 업데이트 하기까지의 프레임 수입니다. 최소값은 1입니다.
		 * @param value
		 * 
		 */
		public function set interval(value:uint):void
		{
			if (value <= 0)
			{
				value = 1;
			}
			_interval = value;
		}
		
		public function get isLoop():Boolean
		{
			return _isLoop;
		}
		
		public function set isLoop(value:Boolean):void
		{
			_isLoop = value;
		}
		
		/**
		 * 일회성 애니메이션일 경우, 모든 애니메이션 프레임 재생 후 전이할 State의 이름입니다. 설정하지 않을 경우 애니메이션 재생이 멈추고 다시 재생하려면 Animator의 transition을 통해 현재 State를 설정해주어야 합니다. 
		 * @return 
		 * 
		 */
		public function get nextState():String
		{
			return _nextState;
		}
		
		/**
		 * 일회성 애니메이션일 경우, 모든 애니메이션 프레임 재생 후 전이할 State의 이름입니다. 설정하지 않을 경우 애니메이션 재생이 멈추고 다시 재생하려면 Animator의 transition을 통해 현재 State를 설정해주어야 합니다. 
		 * @return 
		 * 
		 */
		public function set nextState(value:String):void
		{
			_nextState = value;
		}
		
		/**
		 * Animator의 transition입니다. 일회성 애니메이션일 경우, 해당 함수를 통해 nextState로 전이합니다.  
		 * @param value public function transition(nextStateName:String):void (Animator)
		 * 
		 */
		public function set onEnd(value:Function):void
		{
			_onEnd = value;
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;	
		}
		
		/**
		 * 프레임 수를 카운트하여 다음 애니메이션 인덱스로 넘어갈지 여부를 결정합니다. 일회성 애니메이션일 경우 마지막 인덱스 재생 후, 자신을 stop하고 nextState로 전이합니다.
		 * @param event TrollingEvent.ENTER_FRAME
		 * 
		 */
		private function onNextFrame(event:TrollingEvent):void
		{
			if (!_isPlaying || _isFrozen)
			{
				return;
			}
			
			_frameCounter++;
			
			if (_frameCounter >= _interval)
			{
				_currentIndex++;
				
				if (_currentIndex >= _animation.length)
				{
					if (_isLoop)
					{
						_currentIndex = 0;
					}
					else
					{
						if (_nextState && _onEnd)
						{
							_onEnd(_nextState);
						}
						stop();
					}
				}
				
				_frameCounter = 0;
			}
		}
	}
}