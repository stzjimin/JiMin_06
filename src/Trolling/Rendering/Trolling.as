package Trolling.Rendering 
{
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import Trolling.Object.DisplayObject;
	
	
	public class Trolling
	{        
		private var _rootClass:Class;
		private var _root:DisplayObject;
		private var _viewPort:Rectangle;
		private var _stage:Stage;
		
		private var _started:Boolean = false;
		private var _initRender:Boolean = false;
		
		private var _painter:Painter;
		
		private var _nativeStage:flash.display.Stage;
		private var _nativeOverlay:Sprite;
		
		private static var sPainters:Dictionary = new Dictionary(true);
		
		public function Trolling(rootClass:Class, stage:flash.display.Stage, stage3D:Stage3D = null)
		{
			if (stage == null) throw new ArgumentError("Stage must not be null");
			if (stage3D == null) stage3D = stage.stage3Ds[0];
			
			_rootClass = rootClass;
			trace(stage.width, stage.height);
			_viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			_nativeOverlay = new Sprite();
			
			_stage = new Stage(_viewPort.width, _viewPort.height, stage.color);
			trace("stage init");
			initializeRoot();
			trace("initRoot");
			
			_nativeStage = stage;
			_nativeStage.addChild(_nativeOverlay);
			trace("addNativeOverlay");
			
			_painter = createPainter(stage3D);
			_painter.initPainter(onInitPainter);
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			trace("successed Creater");
		}

		public function get stage():Stage
		{
			return _stage;
		}

		public function set stage(value:Stage):void
		{
			_stage = value;
		}

		private function onInitPainter():void
		{
			_painter.configureBackBuffer(_viewPort);
			_initRender = true;
		}
		
		public function initializeRoot():void
		{
			if(_root == null && _rootClass != null)
			{
				trace("ddd");
				_root = new _rootClass() as DisplayObject;
				_root.x = _stage.x;
				_root.y = _stage.y;
				_root.width = _stage.width;
				_root.height = _stage.height;
				_stage.addChild(_root);
			}
		}
		
		public function start():void
		{
		//	_painter.setProgram();
			_started = true;
		}
		
		public function dispose():void
		{
			
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
			if(_started && _initRender)
			//	trace("ddd");
				render();
		}
		
		private function render():void
		{
			_painter.triangleData.initArray();
			_stage.render(_painter);
			_painter.present();
		}
	}
}