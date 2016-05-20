package trolling.rendering
{
	import flash.geom.Matrix3D;
	
	public class RenderState
	{
		private var _alpha:Number;
		private var _culling:String;
		private var _matrix3d:Matrix3D;
		
		public function RenderState()
		{
			
		}

		public function get matrix3d():Matrix3D
		{
			return _matrix3d;
		}
		
		public function set matrix3d(value:Matrix3D):void
		{
			_matrix3d = value;
		}
		
		public function get culling():String
		{
			return _culling;
		}
		
		public function set culling(value:String):void
		{
			_culling = value;
		}
		
		public function get alpha():Number
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void
		{
			_alpha = value;
		}
	}
}