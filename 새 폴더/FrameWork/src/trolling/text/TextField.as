package trolling.text
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.Font;
	import flash.text.FontStyle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import trolling.component.graphic.Image;
	import trolling.object.GameObject;
	import trolling.rendering.Texture;
	import trolling.utils.Color;

	public class TextField extends GameObject
	{	
		private var _textImage:Image;
		private var _textTexture:Texture;
		
		private var _textFormat:TextFormat;
		
		private var _text:String;
		private var _color:uint;
		private var _fillColor:uint;
		private var _textSize:Number;
		
		public function TextField(width:Number, height:Number, text:String, color:uint = Color.BLACK, fillColor:uint = 0x0)
		{
			super();
			
			super.width = width;
			super.height = height;
			
			_textFormat = new TextFormat();
			_textTexture = new Texture();
			_textImage = new Image(_textTexture);
			addComponent(_textImage);
			
			_text = text;
			_color = color;
			_fillColor = fillColor;
			
			setTextTexture();
		}

		private function setTextTexture():void
		{
			var nativeTextField:flash.text.TextField = new flash.text.TextField();
			nativeTextField.text = _text;
			nativeTextField.textColor = _color;
			nativeTextField.setTextFormat(_textFormat);
			
			var textData:BitmapData = new BitmapData(this.width, this.height, true, _fillColor);
			textData.draw(nativeTextField);
			
			var bitmapText:Bitmap = new Bitmap(textData);
			
			_textTexture.setFromBitmap(bitmapText);
		}
		
		public function get textSize():Number
		{
			return _textSize;
		}
		
		public function set textSize(value:Number):void
		{
			_textSize = value;
			
			_textFormat.size = _textSize;
			setTextTexture();
		}
		
		public function get text():String
		{
			return _text;
		}

		public function set text(value:String):void
		{
			_text = value;
			setTextTexture();
		}
		
		public function get fillColor():uint
		{
			return _fillColor;
		}
		
		public function set fillColor(value:uint):void
		{
			_fillColor = value;
			setTextTexture();
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(value:uint):void
		{
			_color = value;
			setTextTexture();
		}
		
	}
}