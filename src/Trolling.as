package
{
	import flash.display.Stage;
	import flash.geom.Rectangle;

	public class Trolling
	{
		private var _viewPort:Rectangle;
		
		public function Trolling(rootClass:Class, stage:flash.display.Stage)
		{
			_viewPort = new Rectangle(0, 0, stage.width, stage.height);
		}
	}
}