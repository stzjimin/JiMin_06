package trolling.utils
{
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import trolling.core.Trolling;
	
	public class TextureUtil
	{	
		public function TextureUtil()
		{
			
		}
		
		public static function fromBitmapData(bitmap:BitmapData):Array
		{
			var textureInfo:Array = new Array();
			
			var _nativeTexture:flash.display3D.textures.Texture;
			
			var binaryWidth:Number = nextPowerOfTwo(bitmap.width);
			var binaryHeight:Number = nextPowerOfTwo(bitmap.height);
			
//			var matrix:Matrix = new Matrix();
//			matrix.scale(binaryWidth/bitmap.width, binaryHeight/bitmap.height);
			
			_nativeTexture = Trolling.current.context.createTexture(binaryWidth, binaryHeight, Context3DTextureFormat.BGRA, false);
			
			var bitmapData:BitmapData = new BitmapData(binaryWidth, binaryHeight, true, 0x0);
			var rect:Rectangle = new Rectangle();
			rect.width = bitmap.width;
			rect.height = bitmap.height;
			
			bitmapData.copyPixels(bitmap, rect, new Point());
			_nativeTexture.uploadFromBitmapData(bitmapData);
			
			textureInfo.push(_nativeTexture);
//			textureInfo.push((binaryWidth / bitmap.width));
//			textureInfo.push((binaryHeight / bitmap.height));
			textureInfo.push((bitmap.width / binaryWidth));
			textureInfo.push((bitmap.height / binaryHeight));
			
			return textureInfo;
		}
		
		public static function nextPowerOfTwo(v:uint): uint
		{
			v--;
			v |= v >> 1;
			v |= v >> 2;
			v |= v >> 4;
			v |= v >> 8;
			v |= v >> 16;
			v++;
			return v;
		}
	}
}