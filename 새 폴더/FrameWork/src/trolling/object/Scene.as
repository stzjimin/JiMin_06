package trolling.object
{	
	import trolling.rendering.Painter;
	
	public class Scene extends GameObject
	{
		private const TAG:String = "[Scene]";
		
		private var _key:String;
		private var _data:Object;
		
		public function Scene()
		{
			super();
		}
		
		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

		public function get key():String
		{
			return _key;
		}
		
		public function set key(value:String):void
		{
			_key = value;
		}
		
		public function setRenderData(renderPainter:Painter):void
		{
			super.setRenderData(renderPainter);
		}
		
		public override function set pivot(value:String):void
		{
			return;
		}
	}
}