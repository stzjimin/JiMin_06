package trolling.rendering
{
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	
	import trolling.core.Trolling;
	import trolling.utils.Color;

	public class ColliderRenderData extends BatchData
	{	
		private var _colliderTexture:flash.display3D.textures.Texture;
		
		public function ColliderRenderData(color:uint = Color.RED)
		{
			super();
			
			var bitmapData:BitmapData = new BitmapData(16, 16, false, color);
			
			_colliderTexture = Trolling.current.context.createTexture(16, 16, Context3DTextureFormat.BGRA, false);
			_colliderTexture.uploadFromBitmapData(bitmapData);
			
			super.batchTexture = _colliderTexture;
		}
	}
}