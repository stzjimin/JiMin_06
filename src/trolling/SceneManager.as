package trolling
{
	import flash.utils.Dictionary;

	public class SceneManager
	{
		private static var _instance:SceneManager;
	
		private const TAG:String = "[SceneManager]";
		
		private var _scenes:Dictionary; // key: Scene name, value: Scene
		private var _currentScene:String = null;
		
		public function SceneManager()
		{
			_instance = this;
		}
		
		public static function getInstance():SceneManager
		{
			if (!_instance)
			{
				_instance = new SceneManager();
			}
			return _instance;
		}
		
		public function dispose():void
		{
			
		}
		
		public function initialize(initialSceneName:String):Scene
		{
			if (!initialSceneName || initialSceneName == "")
			{
				trace(TAG + "초기화에 실패하였습니다. Scene 이름이 필요합니다.");
				return null;
			}
			
			_scenes = new Dictionary();

			var scene:Scene = new Scene(initialSceneName);
			_scenes[initialSceneName] = scene;

			_currentScene = initialSceneName;
			
			return scene;
		}
		
		public function start():void
		{
			if (_currentScene)
			{
				Scene(_scenes[_currentScene]).activate();
			}
		}
	}
}