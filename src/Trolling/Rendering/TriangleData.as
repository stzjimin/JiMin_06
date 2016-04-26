package Trolling.Rendering 
{
	public class TriangleData
	{
		private var _rawVertexData:Vector.<Number>;
		private var _vertexData:Vector.<Vector.<Number>>;
		private var _rawIndexData:Vector.<uint>;
		private var _indexData:Vector.<Vector.<uint>>;
		
		public function TriangleData()
		{
			_rawVertexData = new Vector.<Number>();
			_vertexData = new Vector.<Vector.<Number>>();
			
			_rawIndexData = new Vector.<uint>();
			_indexData = new Vector.<Vector.<uint>>();
		}

		public function initData():void
		{
			for(var i:int = 0; i < _vertexData.length; i++)
				_rawVertexData = _rawVertexData.concat(_vertexData[i]);
			for(var j:int = 0; j < _indexData.length; j++)
				_rawIndexData = _rawIndexData.concat(_indexData[j]);
		}
		
		public function get rawVertexData():Vector.<Number>
		{
			return _rawVertexData;
		}
		
		public function set rawVertexData(value:Vector.<Number>):void
		{
			_rawVertexData = value;
		}

		public function get indexData():Vector.<Vector.<uint>>
		{
			return _indexData;
		}

		public function set indexData(value:Vector.<Vector.<uint>>):void
		{
			_indexData = value;
		}

		public function get vertexData():Vector.<Vector.<Number>>
		{
			return _vertexData;
		}

		public function set vertexData(value:Vector.<Vector.<Number>>):void
		{
			_vertexData = value;
		}
		
		public function get rawIndexData():Vector.<uint>
		{
			return _rawIndexData;
		}
		
		public function set rawIndexData(value:Vector.<uint>):void
		{
			_rawIndexData = value;
		}
	}
}