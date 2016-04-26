package Trolling.Rendering 
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Rectangle;

	public class Painter
	{
		private var _stage3D:Stage3D;
		private var _context:Context3D;
		private var _triangleData:TriangleData;
		private var _program:Program;
		
		private var _viewPort:Rectangle;
		
		private var _vertexBuffer:VertexBuffer3D;
		private var _indexBuffer:IndexBuffer3D;
		
		private var _backBufferWidth:Number;
		private var _backBufferHeight:Number;
		
		public function Painter(stage3D:Stage3D)
		{
			_stage3D = stage3D;
			_triangleData = new TriangleData();
			_program = new Program();
		}

		public function initPainter():void
		{
			_context = _stage3D.context3D;
			_program.initProgram(_context);
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
			
			_context.configureBackBuffer(viewPort.width, viewPort.height, alias);
			_context.setCulling(Context3DTriangleFace.BACK);
			
			_backBufferWidth = viewPort.width;
			_backBufferHeight = viewPort.height;
		}
		
		public function createVertexBuffer():void
		{
			_vertexBuffer = _context.createVertexBuffer(_triangleData.vertexData.length, 6);
			_vertexBuffer.uploadFromVector(_triangleData.rawVertexData, 0, _triangleData.vertexData.length);
		}
		
		public function createIndexBuffer():void
		{
			_indexBuffer = _context.createIndexBuffer(_triangleData.rawIndexData.length);
			_indexBuffer.uploadFromVector(_triangleData.rawIndexData, 0, _triangleData.rawIndexData.length);
		}
		
		public function setVertextBuffer():void
		{
			_context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context.setVertexBufferAt(1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
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