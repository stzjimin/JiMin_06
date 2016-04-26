package
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;

	public class Program
	{
		private var _vertexShaderAssembler : AGALMiniAssembler;
		private var _fragmentShaderAssembler : AGALMiniAssembler;
		private var _program:Program3D;
		
		public function Program()
		{
			_fragmentShaderAssembler = new AGALMiniAssembler();
			_fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				"tex ft1, v0, fs0 <2d>\n" +
				"mov oc, ft1"
			);
			
			_vertexShaderAssembler = new AGALMiniAssembler();
			_vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" + // pos to clipspace
				"mov v0, va1" // copy UV
			);
		}
		
		public function get program():Program3D
		{
			return _program;
		}

		public function initProgram(context3D:Context3D):void
		{
			_program = context3D.createProgram();
			_program.upload( _vertexShaderAssembler.agalcode, _fragmentShaderAssembler.agalcode);
		}
	}
}