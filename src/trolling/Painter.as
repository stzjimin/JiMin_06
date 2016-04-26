package trolling
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;

	public class Painter
	{
		private var _stage3D:Stage3D;
		private var _context:Context3D;
		private var _vertexData:Data;
		private var _program:Program;
		
		public function Painter(stage3D:Stage3D)
		{
			_stage3D = stage3D;
			_context = _stage3D.context3D;
			_vertexData = new Data();
			_program = new Program();
		}
	}
}