package trolling.rendering
{
	import flash.display.Bitmap;
	import flash.display3D.textures.Texture;
	import flash.geom.Rectangle;
	import trolling.utils.TextureUtil;
	
	
	
	public class Texture
	{
		private var _width:Number;
		private var _height:Number;
		private var _ux:Number;
		private var _vy:Number;
		private var _u:Number;
		private var _v:Number;
		
		private var _nativeTexture:flash.display3D.textures.Texture;
		
		public function Texture(bitmap:Bitmap = null)
		{
			if(bitmap != null)
			{
//				_width = bitmap.width;
//				_height = bitmap.height;
//				
//				var textureInfo:Array = TextureUtil.fromBitmapData(bitmap.bitmapData);
//				
//				_nativeTexture = textureInfo[0];
//				_u = textureInfo[1];
//				_v = textureInfo[2];
//				_ux = 1;
//				_vy = 1;
				setFromBitmap(bitmap);
			}
		}

		public function setFromBitmap(bitmap:Bitmap):void
		{
			if(_nativeTexture != null)
				_nativeTexture.dispose();
			
			_width = bitmap.width;
			_height = bitmap.height;
			
			var textureInfo:Array = TextureUtil.fromBitmapData(bitmap.bitmapData);
			
			_nativeTexture = textureInfo[0];
			_u = textureInfo[1];
//			trace("_u = " + _u);
			_v = textureInfo[2];
//			trace("_v = " + _v);
			_ux = 0;
			_vy = 0;
		}
		
		public function setFromTexture(parentTexture:trolling.rendering.Texture, position:Rectangle):void
		{
			if(_nativeTexture != null)
				_nativeTexture.dispose();
			
			if(parentTexture.nativeTexture == null)
				return;
			_nativeTexture = parentTexture.nativeTexture;
			_width = position.width;
			_height = position.height;
			
			_u = position.width / TextureUtil.nextPowerOfTwo(parentTexture.width);
			_v = position.height / TextureUtil.nextPowerOfTwo(parentTexture.height);
			_ux = position.x / TextureUtil.nextPowerOfTwo(parentTexture.width);
			_vy = position.y / TextureUtil.nextPowerOfTwo(parentTexture.height);
		}
		
		public function get height():Number
		{
			return _height;
		}
		
		public function get width():Number
		{
			return _width;
		}
		
		public function get v():Number
		{
			return _v;
		}
		
		public function get u():Number
		{
			return _u;
		}
		
		public function get vy():Number
		{
			return _vy;
		}
		
		public function set vy(value:Number):void
		{
			_vy = value;
		}
		
		public function get ux():Number
		{
			return _ux;
		}
		
		public function set ux(value:Number):void
		{
			_ux = value;
		}
		
		public function get nativeTexture():flash.display3D.textures.Texture
		{
			return _nativeTexture;
		}
	}
}