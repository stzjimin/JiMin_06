package trolling.rendering
{
	import flash.display3D.textures.Texture;

	public class BatchData
	{
		private var _batchTriangles:Vector.<TriangleData>;
		private var _batchVertex:Vector.<Number>;
		private var _batchIndex:Vector.<uint>;
		private var _triangleNum:uint;
		
		private var _batchTexture:flash.display3D.textures.Texture;
		
		/**
		 *배칭데이터 
		 * 
		 */		
		public function BatchData()
		{
			_batchTriangles = new Vector.<TriangleData>();
		}
		
		public function calculVecrtex():void
		{
			_batchVertex = new Vector.<Number>();
			_batchIndex = new Vector.<uint>();
			
			var triangleData:TriangleData;
			var triangleCount:uint = 0;
			while(_batchTriangles.length != 0)
			{
				triangleData = _batchTriangles.shift();
				
				for(var i:int = 0; i < triangleData.rawIndexData.length; i++)
					triangleData.rawIndexData[i] += triangleCount;
				
				_batchVertex = _batchVertex.concat(triangleData.rawVertexData);
				_batchIndex = _batchIndex.concat(triangleData.rawIndexData);
				
				triangleCount += 4;
			}
		}
		
		public function get batchTexture():flash.display3D.textures.Texture
		{
			return _batchTexture;
		}

		public function set batchTexture(value:flash.display3D.textures.Texture):void
		{
			_batchTexture = value;
		}

		public function get triangleNum():uint
		{
			return _triangleNum;
		}

		public function set triangleNum(value:uint):void
		{
			_triangleNum = value;
		}

		public function get batchIndex():Vector.<uint>
		{
			return _batchIndex;
		}

		public function set batchIndex(value:Vector.<uint>):void
		{
			_batchIndex = value;
		}

		public function get batchVertex():Vector.<Number>
		{
			return _batchVertex;
		}

		public function set batchVertex(value:Vector.<Number>):void
		{
			_batchVertex = value;
		}

		public function get batchTriangles():Vector.<TriangleData>
		{
			return _batchTriangles;
		}

		public function set batchTriangles(value:Vector.<TriangleData>):void
		{
			_batchTriangles = value;
		}

	}
}