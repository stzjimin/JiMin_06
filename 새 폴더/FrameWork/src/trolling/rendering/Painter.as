package trolling.rendering 
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.system.System;
	import flash.utils.getTimer;
	
	import trolling.core.StatsDisplay;
	import trolling.core.Trolling;
	
	public class Painter
	{	
		private static const X_AXIS:Vector3D = Vector3D.X_AXIS;
		private static const Y_AXIS:Vector3D = Vector3D.Y_AXIS;
		private static const Z_AXIS:Vector3D = Vector3D.Z_AXIS;
		
		private var _stage3D:Stage3D;
		private var _context:Context3D;
		
		private var _viewPort:Rectangle;
		
		private var _vertexBuffer:VertexBuffer3D;
		private var _indexBuffer:IndexBuffer3D;
		
		private var _backBufferWidth:Number;
		private var _backBufferHeight:Number;
		
		private var _batchDatas:Vector.<BatchData>;
		private var _currentBatchData:BatchData;
		
		private var _colliderRenderData:ColliderRenderData;
		
		private var _culling:String;
		private var _alpha:Number = 1.0;
		private var _currentMatrix:Matrix3D = new Matrix3D();
		private var _textureFlag:Boolean;
		private var _program:Program;
		
		private var _perspectiveMatrix:Matrix3D = new Matrix3D();
		
		private var _capacity:uint;
		
		private var _stateStack:Vector.<RenderState> = new Vector.<RenderState>();

		public function get perspectiveMatrix():Matrix3D
		{
			return _perspectiveMatrix;
		}

		public function set perspectiveMatrix(value:Matrix3D):void
		{
			_perspectiveMatrix = value;
		}

		private var _moleCallBack:Function;
		
		public function Painter(stage3D:Stage3D)
		{
			_stage3D = stage3D;
			_program = new Program();
			_currentMatrix.identity();
			trace("_currentMatrix.rawData = " + _currentMatrix.rawData);
			trace("Painter Creater");
		}
		
		public function pushState():void
		{
			var state:RenderState = new RenderState();
			state.matrix3d = _currentMatrix.clone();
			state.alpha = _alpha;
			_stateStack.push(state);
		}
		
		public function popState():void
		{
			var state:RenderState = _stateStack.pop();
			_currentMatrix = state.matrix3d.clone();
			_alpha = state.alpha;
		}
		
		public function initPainter(resultFunc:Function):void
		{
			_stage3D.addEventListener(Event.CONTEXT3D_CREATE, initMolehill);
			_stage3D.requestContext3D();
			_moleCallBack = resultFunc;
		}
		
		private function initMolehill(event:Event):void
		{
			_context = _stage3D.context3D;	
			_program.initProgram(_context);
			setProgram();
			_context.setDepthTest(true, Context3DCompareMode.ALWAYS);
			_context.setCulling(Context3DTriangleFace.BACK);
			_context.setBlendFactors(
				Context3DBlendFactor.SOURCE_ALPHA,
				Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA
			);
			
			_moleCallBack(_context);
			initBatchDatas();
		}
		
		public function configureBackBuffer(stageRectangle:Rectangle, antiAlias:Boolean = true):void
		{
			_stage3D.x = stageRectangle.x;
			_stage3D.y = stageRectangle.y;
			
			_viewPort = Trolling.current.viewPort;
			trace(_viewPort);
			
			var alias:int;
			if(antiAlias)
				alias = 1;
			else
				alias = 0;
			
			trace(stageRectangle.width + ", " + stageRectangle.height);
			_context.configureBackBuffer(stageRectangle.width, stageRectangle.height, alias, true);
			_context.setCulling(Context3DTriangleFace.BACK);
			
			_backBufferWidth = stageRectangle.width;
			_backBufferHeight = stageRectangle.height;
		}
		
		public function setDrawData(batchData:BatchData):void
		{	
			createVertexBuffer(batchData);
			createIndexBuffer(batchData);
			setVertextBuffer();
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, new <Number>[1, 1, 1, 1]);
//			setUVVector(batchData);
//			_matrix.appendRotation(90, Z_AXIS);
//			_matrix.appendTranslation(0, -0.5, 0);
//						_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _matrix, true);
			
			var matrix:Matrix3D = new Matrix3D();
//			matrix.appendRotation(-90, Vector3D.Z_AXIS);
//			matrix.appendTranslation(-(_viewPort.width/2), (_viewPort.height/2), 0);
//			matrix.appendScale((2/_viewPort.width), (2/_viewPort.height), 1);
//			matrix.prependTranslation(-(Trolling.current.currentScene.width/2), (Trolling.current.currentScene.height/2), 0);
//			matrix.prependScale((2/_viewPort.width), (2/_viewPort.height), 1);
//			matrix.copyColumnFrom(0, vector0);
//			matrix.copyColumnFrom(1, vector1);
//			matrix.copyColumnFrom(2, vector2);
//			matrix.copyColumnFrom(3, vector3);
			
//			var perspectiveMatrix:Matrix3D = new Matrix3D();
//			var vector0:Vector3D = new Vector3D(1, 0, 0, 0);
//			var vector1:Vector3D = new Vector3D(0, 1, 0, 0);
//			var vector2:Vector3D = new Vector3D(0, 0, 2, -2);
//			var vector3:Vector3D = new Vector3D(0, 0, 1, 0);
//			
//			perspectiveMatrix.copyColumnFrom(0, vector0);
//			perspectiveMatrix.copyColumnFrom(1, vector1);
//			perspectiveMatrix.copyColumnFrom(2, vector2);
//			perspectiveMatrix.copyColumnFrom(3, vector3);
			
//			_currentMatrix.appendScale((2/_viewPort.width), (2/_viewPort.height), 1);
			
//			trace("matrix = " + matrix.rawData);
			_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);
			
			_context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, new <Number>[1, 1, 1, 1], 1);
		}
		
		private function createVertexBuffer(batchData:BatchData):void
		{
			_vertexBuffer = _context.createVertexBuffer(batchData.batchVertex.length/9, 9);
			_vertexBuffer.uploadFromVector(batchData.batchVertex, 0, batchData.batchVertex.length/9);
		}
		
		private function createIndexBuffer(batchData:BatchData):void
		{
			_indexBuffer = _context.createIndexBuffer(batchData.batchIndex.length);
			_indexBuffer.uploadFromVector(batchData.batchIndex, 0, batchData.batchIndex.length);
		}
		
		private function setVertextBuffer():void
		{
			_context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
			_context.setVertexBufferAt(2, _vertexBuffer, 5, Context3DVertexBufferFormat.FLOAT_4);
		}
		
		public function present():void
		{
			_context.present();
			initBatchDatas();
		}
		
		public function initBatchDatas():void
		{
			_batchDatas = new Vector.<BatchData>();
			_currentBatchData = null;
			_colliderRenderData = new ColliderRenderData();
		}
		
		public function batchDraw():void
		{
			if(_colliderRenderData.batchTriangles.length != 0)
				_batchDatas.push(_colliderRenderData);
			var batchData:BatchData;
			while(_batchDatas.length != 0)
			{
				batchData = _batchDatas.shift();
				_context.setTextureAt(0, batchData.batchTexture);
				batchData.calculVecrtex();
				setDrawData(batchData);
				draw();
			}
			if(Trolling.current.statsVisible)
			{
				var memory:Number = System.totalMemory * 0.000000954;
				Trolling.current.statsTextField.text = "drawCall = " + Trolling.current.drawCall + "\n" + "memory = " + memory.toFixed(memory < 100 ? 1 : 0);
				
				var statsBatch:StatsDisplay = new StatsDisplay();
				statsBatch.statsTextField = Trolling.current.statsTextField;
				statsBatch.setStatsTriangle();
				_context.setTextureAt(0, statsBatch.batchTexture);
				statsBatch.calculVecrtex();
				setDrawData(statsBatch);
				draw();
				statsBatch = null;
			}
		}
		
		public function draw():void
		{
			Trolling.current.drawCall++;
			_context.drawTriangles(_indexBuffer);
			clearBuffer();
		}
		
		private function clearBuffer():void
		{
			if(_vertexBuffer)
				clearVertextBuffer();
			if(_indexBuffer)
				clearIndexBuffer();
		}
		
		private function clearVertextBuffer():void
		{
			_context.setVertexBufferAt(0, null);
			_context.setVertexBufferAt(1, null);
			_context.setVertexBufferAt(2, null);
			_vertexBuffer.dispose();
			_vertexBuffer = null;
		}
		
		private function clearIndexBuffer():void
		{
			_indexBuffer.dispose();
			_indexBuffer = null;
		}
		
		private function setProgram():void
		{
			_context.setProgram(_program.program);
		}
		
		public function get viewPort():Rectangle
		{
			return _viewPort;
		}
		
		public function set viewPort(value:Rectangle):void
		{
			_viewPort = value;
		}
		
		public function get textureFlag():Boolean
		{
			return _textureFlag;
		}
		
		public function set textureFlag(value:Boolean):void
		{
			_textureFlag = value;
		}
		
		public function get matrix3d():Matrix3D
		{
			return _currentMatrix;
		}
		
		public function set matrix3d(value:Matrix3D):void
		{
			_currentMatrix = value;
		}
		
		public function get culling():String
		{
			return _culling;
		}
		
		public function set culling(value:String):void
		{
			_culling = value;
		}
		
		public function get program():Program
		{
			return _program;
		}
		
		public function set program(value:Program):void
		{
			_program = value;
		}
		
		public function get context():Context3D
		{
			return _context;
		}
		
		public function set context(value:Context3D):void
		{
			_context = value;
		}
		
		public function get alpha():Number
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void
		{
			_alpha = value;
		}
		
		public function get currentBatchData():BatchData
		{
			return _currentBatchData;
		}
		
		public function set currentBatchData(value:BatchData):void
		{
			_currentBatchData = value;
		}
		
		public function get batchDatas():Vector.<BatchData>
		{
			return _batchDatas;
		}
		
		public function set batchDatas(value:Vector.<BatchData>):void
		{
			_batchDatas = value;
		}
		
		public function get colliderRenderData():ColliderRenderData
		{
			return _colliderRenderData;
		}
		
		public function set colliderRenderData(value:ColliderRenderData):void
		{
			_colliderRenderData = value;
		}
	}
}