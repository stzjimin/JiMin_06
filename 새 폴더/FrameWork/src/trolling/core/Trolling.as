package trolling.core
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import trolling.event.TouchPhase;
	import trolling.event.TrollingEvent;
	import trolling.media.SoundManager;
	import trolling.object.GameObject;
	import trolling.object.Scene;
	import trolling.object.Stage;
	import trolling.rendering.Painter;
	import trolling.text.TextField;
	import trolling.utils.Color;
	
	public class Trolling
	{        
		private const TAG:String = "[Trolling]";
		
		private static var sPainters:Dictionary = new Dictionary(true);
		private static var _current:Trolling;
		
		private var _sceneDic:Dictionary;
		private var _createQueue:Array = new Array();
		
		private var _currentScene:Scene;
		private var _viewPort:Rectangle;
		private var _stage:Stage;
		
		private var _started:Boolean = false;
		private var _initRender:Boolean = false;
		
		private var _painter:Painter;
		
		private var _nativeStage:flash.display.Stage;
		
		private var _context:Context3D = null;
		
		private var _vfr:uint;
		
		//Management
		private var _colliderManager:ColliderManager = new ColliderManager();
		private var _touchs:Dictionary = new Dictionary();
		//
		
		private var _statsVisible:Boolean;
		private var _statsTextField:TextField;
		private var _drawCall:uint;
		
		public function Trolling(stage:flash.display.Stage, viewPort:Rectangle = null, fullScreen:Rectangle = null, stage3D:Stage3D = null)
		{
			if (stage == null) throw new ArgumentError("Stage must not be null");
			if (stage3D == null) stage3D = stage.stage3Ds[0];
			if (viewPort == null) viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			if (fullScreen == null) fullScreen = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			_current = this;
			
			trace(stage.width, stage.height);
			trace(stage.frameRate);
			_viewPort = viewPort;
			
			_stage = new Stage(fullScreen.width, fullScreen.height, stage.color);
			trace("stage init");
			_nativeStage = stage;
			trace("addNativeOverlay");
			
			_painter = createPainter(stage3D);
			_painter.initPainter(onInitPainter);
			
			stage.addEventListener(Event.ACTIVATE, onActivate);
			stage.addEventListener(Event.DEACTIVATE, onDeactivate);
			trace("successed Creater");
			
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouch);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouch);
			stage.addEventListener(TouchEvent.TOUCH_END, onTouch);
			stage.addEventListener(TouchEvent.TOUCH_OVER, onTouch);
			
			if(!multitouchEnabled)
			{
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onTouch);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onTouch);
				stage.addEventListener(MouseEvent.MOUSE_UP, onTouch);
			}
			
			//change
//			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey, false, 0, true);
//			stage.addEventListener(KeyboardEvent.KEY_UP, onKey, false, 0, true);
//			stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
			calculVFR(stage);
			
//			trace("_vfr = " + _vfr);
		}

		public function get nativeStage():flash.display.Stage
		{
			return _nativeStage;
		}

		public function set nativeStage(value:flash.display.Stage):void
		{
			_nativeStage = value;
		}

		private function calculVFR(stage:flash.display.Stage):void
		{
			_vfr = 0;
			
			stage.addEventListener(Event.ENTER_FRAME, onEnteredFrame);
			var time:Number = getTimer() / 1000.0;
			
			function onEnteredFrame():void
			{
				_vfr++;
				
				var timeTemp:Number = getTimer() / 1000.0;
				if((timeTemp - time) >= 1.0)
				{
					stage.removeEventListener(Event.ENTER_FRAME, onEnteredFrame);
					trace("_vfr = " + _vfr);
				}
			}
		}
		
		private function onTouch(event:Event):void
		{
			if(_currentScene == null)
				return;
			
			var globalX:Number;
			var globalY:Number;
			var touchID:int;
			var phase:String;
			var pressure:Number = 1.0;
			var width:Number = 1.0;
			var height:Number = 1.0;
			
			// figure out general touch properties
			if (event is MouseEvent)
			{
				var mouseEvent:MouseEvent = event as MouseEvent;
				globalX = mouseEvent.stageX;
				globalY = mouseEvent.stageY;
				touchID = 0;
				
				// MouseEvent.buttonDown returns true for both left and right button (AIR supports
				// the right mouse button). We only want to react on the left button for now,
				// so we have to save the state for the left button manually.
				//if (event.type == MouseEvent.MOUSE_DOWN)    _leftMouseDown = true;
				//else if (event.type == MouseEvent.MOUSE_UP) _leftMouseDown = false;
			}
			else
			{
				var touchEvent:TouchEvent = event as TouchEvent;
				
				// On a system that supports both mouse and touch input, the primary touch point
				// is dispatched as mouse event as well. Since we don't want to listen to that
				// event twice, we ignore the primary touch in that case.
				
				if (Mouse.supportsCursor && touchEvent.isPrimaryTouchPoint) return;
				else
				{
					globalX  = touchEvent.stageX;
					globalY  = touchEvent.stageY;
					touchID  = touchEvent.touchPointID;
					pressure = touchEvent.pressure;
					width    = touchEvent.sizeX;
					height   = touchEvent.sizeY;
				}
			}
			
			switch (event.type)
			{
				case TouchEvent.TOUCH_BEGIN: phase = TouchPhase.BEGAN; break;
				case TouchEvent.TOUCH_MOVE:  phase = TouchPhase.MOVED; break;
				case TouchEvent.TOUCH_END:   phase = TouchPhase.ENDED; break;
				case MouseEvent.MOUSE_MOVE:  phase = TouchPhase.MOVED; break;
				case MouseEvent.MOUSE_DOWN:  phase = TouchPhase.BEGAN; break;
				case MouseEvent.MOUSE_UP:    phase = TouchPhase.ENDED; break;
				case TouchEvent.TOUCH_OVER:  phase = TouchPhase.HOVER; break;
			}
			
			// move position into viewport bounds
//			globalX = _stage.stageWidth  * (globalX - _viewPort.x) / _viewPort.width;
//			globalY = _stage.stageHeight * (globalY - _viewPort.y) / _viewPort.height;
			globalX = (globalX - _viewPort.x) * (_viewPort.width / _stage.stageWidth);
			globalY = (globalY - _viewPort.y) * (_viewPort.height / _stage.stageHeight);
			
			
			var point:Point = new Point(globalX, globalY);
			var hit:GameObject;
			
			if(phase == TouchPhase.BEGAN)
			{
				if(!_touchs[touchID])
				{
					var touchManager:TouchManager = new TouchManager();
					_touchs[touchID] = touchManager;
				}
				_touchs[touchID].pushPoint(point);
				hit = _currentScene.findClickedGameObject(point);
				if(hit != null)
					hit.dispatchEvent(new TrollingEvent(TrollingEvent.TOUCH_BEGAN, _touchs[touchID].points));
				_touchs[touchID].hoverFlag = true;
				_touchs[touchID].hoverTarget = hit;
			}
			else if(phase == TouchPhase.MOVED)
			{
				if(!_touchs[touchID])
				{
					touchManager = new TouchManager();
					_touchs[touchID] = touchManager;
				}
				_touchs[touchID].pushPoint(point);
				hit = _currentScene.findClickedGameObject(point);
				if(hit != null)
					hit.dispatchEvent(new TrollingEvent(TrollingEvent.TOUCH_MOVED, _touchs[touchID].points));
				if(hit != _touchs[touchID].hoverTarget)
				{
					if(_touchs[touchID].hoverTarget != null)
						_touchs[touchID].hoverTarget.dispatchEvent(new TrollingEvent(TrollingEvent.TOUCH_OUT, _touchs[touchID].points));
					_touchs[touchID].hoverTarget = hit;
					if(hit != null)
						hit.dispatchEvent(new TrollingEvent(TrollingEvent.TOUCH_IN, _touchs[touchID].points));
				}
			}
			else if(phase == TouchPhase.ENDED)
			{
				if(!_touchs[touchID])
				{
					touchManager = new TouchManager();
					_touchs[touchID] = touchManager;
				}
				hit = _currentScene.findClickedGameObject(point);
				if(hit != null && _touchs[touchID].points.length != 0)
					hit.dispatchEvent(new TrollingEvent(TrollingEvent.TOUCH_ENDED, _touchs[touchID].points));
				_touchs[touchID].hoverFlag = false;
//				_touchs[touchID] = null;
				delete _touchs[touchID];
			}
		}
		
		private function onInitPainter(context:Context3D):void
		{
			_painter.configureBackBuffer(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight));
			_context = context;
			trace("createContext");
			createSceneFromQueue();
			_initRender = true;
			trace("initRoot");
			trace(_currentScene.key);
			_nativeStage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_statsTextField = new TextField(100, 40, "drawCall = 0", Color.RED, Color.argb(100, 100, 100, 100));
		}
		
		private function createSceneFromQueue():void
		{
			var arrayTemp:Array;
			while(_createQueue.length != 0)
			{
				arrayTemp = _createQueue.shift();
				SceneManager.addScene(arrayTemp[0], arrayTemp[1]);
			}
			arrayTemp = null;
			_createQueue = null;
		}
		
		//change
		private function nextFrame():void
		{
			_currentScene.dispatchEvent(new TrollingEvent(TrollingEvent.ENTER_FRAME));
		}
		
		public function start():void
		{
			_started = true;
		}
		
		private function createPainter(stage3D:Stage3D):Painter
		{
			if (stage3D in sPainters)
				return sPainters[stage3D];
			else
			{
				var painter:Painter = new Painter(stage3D);
				sPainters[stage3D] = painter;
				return painter;
			}
		}
		
		private function onEnterFrame(event:Event):void
		{
			if(!_started || !_painter.context)
				return;
			
			for(var key:String in _touchs)
			{
				if(_touchs[key] && _touchs[key].hoverFlag && (_touchs[key].hoverTarget != null))
				{
					_touchs[key].hoverTarget.dispatchEvent(new TrollingEvent(TrollingEvent.TOUCH_HOVER, _touchs[key].points));
				}
			}
			
			Disposer.disposeObjects();
			_colliderManager.detectCollision();
			nextFrame();
			render();
		}
		
		private function render():void
		{
			_drawCall = 0;
			_painter.context.setRenderToBackBuffer();
			_painter.context.clear(Color.getRed(_stage.color)/255.0, Color.getGreen(_stage.color)/255.0, Color.getBlue(_stage.color)/255.0);
			
			_currentScene.setRenderData(_painter);
			_painter.batchDraw();
			_painter.present();
		}
		
		private function onActivate(event:Event):void
		{
			trace("온엑");
			_nativeStage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			SoundManager.wakeBgm();
		}
		
		private function onDeactivate(event:Event):void
		{
			trace("디엑");
			_nativeStage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			SoundManager.stopAll();
		}
		
		public function get colliderManager():ColliderManager
		{
			return _colliderManager;
		}
		
		public function set currentScene(value:Scene):void
		{
			_currentScene = value;
		}
		
		public function get createQueue():Array
		{
			return _createQueue;
		}
		
		public function set createQueue(value:Array):void
		{
			_createQueue = value;
		}
		
		public function get currentScene():Scene
		{
			return _currentScene;
		}
		
		public function get painter():Painter
		{
			return _painter;
		}
		
		public function set painter(value:Painter):void
		{
			_painter = value;
		}
		
		public static function get painter():Painter
		{
			return _current.painter;
		}
		
		public function get profile():String
		{
			if(_context)
				return _context.profile;
			else
				return null;
		}
		
		public function get context():Context3D
		{
			return _context;
		}
		
		public function set context(value:Context3D):void
		{
			_context = value;
		}
		
		public static function get current():Trolling
		{
			return _current;
		}
		
		public function get stage():Stage
		{
			return _stage;
		}
		
		public function set stage(value:Stage):void
		{
			_stage = value;
		}
		
		public function get drawCall():uint
		{
			return _drawCall;
		}
		
		public function set drawCall(value:uint):void
		{
			_drawCall = value;
		}
		
		public function get viewPort():Rectangle
		{
			return _viewPort;
		}
		
		public function set viewPort(value:Rectangle):void
		{
			_viewPort = value;
		}
		
		public function get statsVisible():Boolean
		{
			return _statsVisible;
		}
		
		public function set statsVisible(value:Boolean):void
		{
			_statsVisible = value;
		}
		
		public function get statsTextField():TextField
		{
			return _statsTextField;
		}
		
		public function set statsTextField(value:TextField):void
		{
			_statsTextField = value;
		}
		
		public static function get multitouchEnabled():Boolean
		{ 
			return Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT;
		}
		
		public static function set multitouchEnabled(value:Boolean):void
		{
			if (_current) throw new IllegalOperationError(
				"'multitouchEnabled' must be set before Trolling instance is created");
			else 
				Multitouch.inputMode = value ? MultitouchInputMode.TOUCH_POINT :
												MultitouchInputMode.NONE;
		}
	}
}