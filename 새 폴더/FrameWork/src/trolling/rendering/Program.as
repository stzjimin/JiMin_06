package trolling.rendering 
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	public class Program
	{
		private var _vertexShaderAssembler : AGALMiniAssembler;
		private var _fragmentShaderAssembler : AGALMiniAssembler;
		
		private var _vertexShaderAssemblerTemp : AGALMiniAssembler;
		
		private var _fragmentShaderAssembler1 : AGALMiniAssembler;
		private var _fragmentShaderAssembler3 : AGALMiniAssembler;
		
		private var _program:Program3D;
		
		public function Program()
		{	
//			_vertexShaderAssembler = new AGALMiniAssembler();
//			_vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
//				// Apply draw matrix (object -> clip space)
//				"m44 op, va0, vc0\n" +
//				
//				// Scale texture coordinate and copy to varying
//				"mov vt0, va1\n" +
//				"div vt0.xy, vt0.xy, vc4.xy\n" +
//				"mov v0, vt0\n"
//			);
			
//			_fragmentShaderAssembler = new AGALMiniAssembler();
//			_fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
//				"tex ft1, v0, fs0 <2d,linear,mipnone,clamp>\n" + 
//				"mul oc, ft1, fc0\n"
//			);
			
			_vertexShaderAssembler = new AGALMiniAssembler();
			_vertexShaderAssembler.assemble
				( 
					Context3DProgramType.VERTEX,
					"m44 op, va0, vc0 \n" + 
					"mov v0, va0 \n" + // tell fragment shader about XYZ
					"mov v1, va1 \n" + // tell fragment shader about UV
					"mov v2, va2\n"   // tell fragment shader about RGBA
				);
			
//			_fragmentShaderAssembler1 = new AGALMiniAssembler();
//			_fragmentShaderAssembler1.assemble
//				( 
//					Context3DProgramType.FRAGMENT,	
//					// grab the texture color from texture 0 
//					// and uv coordinates from varying register 1
//					// and store the interpolated value in ft0
//					"tex ft0, v1, fs0 <2d,repeat,miplinear>\n" +	
//					// move this value to the output color
//					"mov oc, ft0\n"
//				);
			
			// textured using UV coordinates AND colored by vertex RGB
			_fragmentShaderAssembler3 = new AGALMiniAssembler();
			_fragmentShaderAssembler3.assemble
				( 
					Context3DProgramType.FRAGMENT,	
					"tex ft0, v1, fs0 <2d,clamp,linear> \n" + 
//					"mul ft0.a, ft0.a, fc0.x\n" + // manage alpha value that is set as program constant
					"mul ft1, v2, ft0\n" +
					"mov oc, ft1 \n" // move this value to the output color
				);
		}
		
		public function get program():Program3D
		{
			return _program;
		}
		
		public function initProgram(context:Context3D):void
		{
			_program = context.createProgram();
			
			_program.upload( _vertexShaderAssembler.agalcode, _fragmentShaderAssembler3.agalcode);
//			_program.upload( _vertexShaderAssembler.agalcode, _fragmentShaderAssembler.agalcode);
		}
	}
}