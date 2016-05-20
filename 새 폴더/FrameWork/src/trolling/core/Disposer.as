package trolling.core
{	
	import trolling.object.GameObject;
	
	public class Disposer
	{	
		private static var _gameObjects:Vector.<GameObject>;
		
		public function Disposer()
		{
			
		}
		
		public static function requestDisposal(target:GameObject):void
		{
			if (!target)
			{
				return;
			}
			
			if (!_gameObjects)
			{
				_gameObjects = new Vector.<GameObject>();
			}
			_gameObjects.push(target);
		}
		
		public static function disposeObjects():void
		{
			if (_gameObjects)
			{
				for (var i:int = 0; i < _gameObjects.length; i++)
				{
					_gameObjects[i].removeFromParent();
				}
				_gameObjects.splice(0, _gameObjects.length);
			}
			_gameObjects = null;
		}
	}
}