package Trolling.Component.Graphic
{
	import flash.display.BitmapData;
	
	import Trolling.Component.ComponentType;
	import Trolling.Component.DisplayComponent;
	import Trolling.Object.DisplayObject;

	public class Image extends DisplayComponent
	{
		private const TAG:String = "[Image]";

		private var _bitmapData:BitmapData;
		
		public function Image(name:String, parent:DisplayObject, resource:BitmapData)
		{
			super(ComponentType.IMAGE, name, parent);
			
			_bitmapData = resource;
		}
		
		public override function dispose():void
		{
			if (_bitmapData)
			{
				//_bitmapData.dispose();
			}
			_bitmapData = null;
			
			super.dispose();
		}
		
		public override function getRenderingResource():BitmapData
		{
			if (_bitmapData)
			{
				return _bitmapData;
			}
			else
			{
				return null;
			}
		}
	}
}