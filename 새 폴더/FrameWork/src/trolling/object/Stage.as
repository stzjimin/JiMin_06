package trolling.object
{	
	public class Stage
	{	
		private var _width:Number;
		private var _height:Number;
		private var _color:uint;
		
		public function Stage(stageWidth:Number, stageHeight:Number, color:uint=0)
		{
			_width = stageWidth;
			_height = stageHeight;
			_color = color;
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(value:uint):void
		{
			_color = value;
		}
		
		public function get stageHeight():Number
		{
			return _height;
		}
		
		public function set stageHeight(value:Number):void
		{
			_height = value;
		}
		
		public function get stageWidth():Number
		{
			return _width;
		}
		
		public function set stageWidth(value:Number):void
		{
			_width = value;
		}
	}
}