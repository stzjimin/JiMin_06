package trolling.rendering 
{
	public class TriangleData
	{
		private var _rawIndexData:Vector.<uint> = 
			Vector.<uint>([
				0, 1, 2,
				2, 3, 0]);
		
		private var _rawVertexData:Vector.<Number> = new Vector.<Number>();
		
		public function TriangleData()
		{
			
		}
		
		/**
		 *삼각형을 구성하기 위한 각 정점에 대한 정보 
		 * @return 
		 * 
		 */		
		public function get rawVertexData():Vector.<Number>
		{
			return _rawVertexData;
		}
		
		/**
		 *삼각형을 구성하기 위한 각 정점에 대한 정보 
		 * @return 
		 * 
		 */		
		public function set rawVertexData(value:Vector.<Number>):void
		{
			_rawVertexData = value;
		}
		
		/**
		 *하나의 삼각형을 어떤 정점들이 구성하고있는지에 대한 정보 
		 * @return 
		 * 
		 */		
		public function get rawIndexData():Vector.<uint>
		{
			return _rawIndexData;
		}
		
		/**
		 *하나의 삼각형을 어떤 정점들이 구성하고있는지에 대한 정보 
		 * @return 
		 * 
		 */		
		public function set rawIndexData(value:Vector.<uint>):void
		{
			_rawIndexData = value;
		}
	}
}