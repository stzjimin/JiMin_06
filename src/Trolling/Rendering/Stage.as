package Trolling.Rendering 
{
	import Trolling.Object.DisplayObject;

	public class Stage extends DisplayObject
	{	
	//	private var _width:int;
	//	private var _height:int;
		private var _color:uint;
		
		public function Stage(stageWidth:int, stageHeight:int, color:uint=0)
		{
			width = stageWidth;
			height = stageHeight;
			_color = color;
		}
	}
}