package trolling.core
{
	import flash.geom.Rectangle;
	
	import trolling.component.ComponentType;
	import trolling.component.graphic.Image;
	import trolling.rendering.BatchData;
	import trolling.rendering.TriangleData;
	import trolling.text.TextField;

	public class StatsDisplay extends BatchData
	{
		private var _statsTextField:TextField;
		
		public function StatsDisplay()
		{
			super();
		}

		public function setStatsTriangle():void
		{
			var textImage:Image = _statsTextField.components[ComponentType.IMAGE];
			var textureRect:Rectangle = new Rectangle(textImage.texture.ux, textImage.texture.vy, textImage.texture.u, textImage.texture.v);
			
			var statsTriangle:TriangleData = new TriangleData();
			statsTriangle.rawVertexData = statsTriangle.rawVertexData.concat(Vector.<Number>([-1, 1, 0, textureRect.x, textureRect.y, 1, 1, 1, 1]));
			statsTriangle.rawVertexData = statsTriangle.rawVertexData.concat(Vector.<Number>([-0.8, 1, 0, textureRect.x+textureRect.width, textureRect.y, 1, 1, 1, 1]));
			statsTriangle.rawVertexData = statsTriangle.rawVertexData.concat(Vector.<Number>([-0.8, 0.9, 0, textureRect.x+textureRect.width, textureRect.y+textureRect.height, 1, 1, 1, 1]));
			statsTriangle.rawVertexData = statsTriangle.rawVertexData.concat(Vector.<Number>([-1, 0.9, 0, textureRect.x, textureRect.y+textureRect.height, 1, 1, 1, 1]));
			
			this.batchTexture = textImage.texture.nativeTexture;
			this.batchTriangles.push(statsTriangle);
		}
		
		public function get statsTextField():TextField
		{
			return _statsTextField;
		}
		
		public function set statsTextField(value:TextField):void
		{
			_statsTextField = value;
		}
	}
}