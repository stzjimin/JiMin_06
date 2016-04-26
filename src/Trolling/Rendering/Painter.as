package Trolling.Rendering 
{
	import flash.display.Bitmap;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;

	public class Painter
	{
		[Embed( source = "iu3.jpg" )]
		protected const TextureBitmap:Class;
		protected var texture:Texture;
		
		private var _stage3D:Stage3D;
		private var _context:Context3D;
		private var _triangleData:TriangleData;
		private var _program:Program;
		
		private var _viewPort:Rectangle;
		
		private var _vertexBuffer:VertexBuffer3D;
		private var _indexBuffer:IndexBuffer3D;
		
		private var _backBufferWidth:Number;
		private var _backBufferHeight:Number;
		
		private var _moleCallBack:Function;
		
		public function Painter(stage3D:Stage3D)
		{
			_stage3D = stage3D;
			_triangleData = new TriangleData();
			_program = new Program();
			trace("Painter Creater");
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
			setProgram();
			_program.initProgram(_context);
			_moleCallBack();
		}
		
		public function configureBackBuffer(viewPort:Rectangle, antiAlias:Boolean = true):void
		{
			_stage3D.x = viewPort.x;
			_stage3D.y = viewPort.y;
			
			_viewPort = viewPort;
			
			var alias:int;
			if(antiAlias)
				alias = 1;
			else
				alias = 0;
			
			trace(viewPort.width + ", " + viewPort.height);
			_context.configureBackBuffer(viewPort.width, viewPort.height, alias);
			_context.setCulling(Context3DTriangleFace.BACK);
			
			_backBufferWidth = viewPort.width;
			_backBufferHeight = viewPort.height;
		}
		
		public function present():void
		{
			var bitmap:Bitmap = new TextureBitmap();
			texture = _context.createTexture(512, 1024, Context3DTextureFormat.BGRA, false);
			texture.uploadFromBitmapData(bitmap.bitmapData);
			
			_triangleData.initData();
			_context.clear(1, 1, 1);
			createVertexBuffer();
			createIndexBuffer();
			setVertextBuffer();
			setMatrix();
			_context.setTextureAt(0, texture);
			_context.drawTriangles(_indexBuffer, 0, _triangleData.indexData.length);
			_context.present();	
		}
		
		public function createVertexBuffer():void
		{
			_vertexBuffer = _context.createVertexBuffer(_triangleData.vertexData.length, 5);
			trace("_triangleData.vertexData.length = " + _triangleData.vertexData.length);
			trace("_triangleData.rawVertexData = " + _triangleData.rawVertexData.length);
			_vertexBuffer.uploadFromVector(_triangleData.rawVertexData, 0, _triangleData.vertexData.length);
		}
		
		public function createIndexBuffer():void
		{
			_indexBuffer = _context.createIndexBuffer(_triangleData.rawIndexData.length);
			trace("_triangleData.rawIndexData.length = " + _triangleData.rawIndexData.length);
			_indexBuffer.uploadFromVector(_triangleData.rawIndexData, 0, _triangleData.rawIndexData.length);
		}
		
		public function setVertextBuffer():void
		{
			_context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
		}
		
		public function setMatrix():void
		{
			var m:Matrix3D = new Matrix3D();
			_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
		}
		
		public function setProgram():void
		{
			_context.setProgram(_program.program);
		}
		
		public function get triangleData():TriangleData
		{
			return _triangleData;
		}
		
		public function set triangleData(value:TriangleData):void
		{
			_triangleData = value;
		}
		
		public function get viewPort():Rectangle
		{
			return _viewPort;
		}
		
		public function set viewPort(value:Rectangle):void
		{
			_viewPort = value;
		}
	}
}