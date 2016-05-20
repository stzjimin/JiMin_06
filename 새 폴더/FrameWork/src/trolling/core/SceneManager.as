package trolling.core
{
	//change
	import flash.utils.Dictionary;
	
	import trolling.event.TrollingEvent;
	import trolling.media.SoundManager;
	import trolling.object.Scene;
	import trolling.utils.Copy;
	
	public class SceneManager
	{	
		private static var _sceneDic:Dictionary;
		private static var _sceneVector:Vector.<Scene> = new Vector.<Scene>();
		
		public function SceneManager()
		{
			
		}
		
		public static function dispose():void
		{
			if (_sceneDic)
			{
				for (var key:Object in _sceneDic)
				{
					var scene:Scene = _sceneDic[key];
					if (scene)
					{
						scene.dispose();
					}
				}
			}
			_sceneDic = null;
			
			if (_sceneVector)
			{
				for (var i:int = 0; i < _sceneVector.length; i++)
				{
					scene = _sceneVector[i];
					if (scene)
					{
						scene.dispose();
					}
				}
			}
			_sceneVector = null;
		}
		
		/**
		 *현제의 Scene을  
		 * @param key
		 * 
		 */		
		public static function goScene(key:String, data:Object = null):void
		{
			if(_sceneDic == null || _sceneDic[key] == null)
				return;
			
			if(Trolling.current.currentScene != null)
			{
				Trolling.current.currentScene.visible = false;
				SoundManager.dispose();
				_sceneVector.push(_sceneDic[Trolling.current.currentScene.key]);
				Trolling.current.currentScene.dispatchEvent(new TrollingEvent(TrollingEvent.END_SCENE));
			}
			
			Trolling.current.currentScene = _sceneDic[key];
			Trolling.current.currentScene.visible = true;
			Trolling.current.currentScene.data = Copy.clone(data);
			Trolling.current.currentScene.dispatchEvent(new TrollingEvent(TrollingEvent.START_SCENE));
		}
		
		public static function outScene(data:Object = null):void
		{
			var scene:Scene = _sceneVector.pop();
			var key:String = Trolling.current.currentScene.key;
			switchScene(scene.key, data);
			deleteScene(key);
		}
		
		public static function addScene(sceneClass:Class, key:String):void
		{
			if(_sceneDic && _sceneDic[key] != null)
				return;
			if(Trolling.current.context == null)
			{
				var addArray:Array = new Array();
				addArray.push(sceneClass);
				addArray.push(key);
				Trolling.current.createQueue.push(addArray);
				return;    
			}
			var scene:Scene = new sceneClass() as Scene;
			scene.key = key;
			if(!_sceneDic)
			{
				_sceneDic = new Dictionary();
				Trolling.current.currentScene = scene;
				_sceneDic[key] = scene;
				scene.width = Trolling.current.viewPort.width;
				scene.height = Trolling.current.viewPort.height;
				scene.dispatchEvent(new TrollingEvent(TrollingEvent.START_SCENE));
			}
			else
			{
				_sceneDic[key] = scene;
				scene.width = Trolling.current.viewPort.width;
				scene.height = Trolling.current.viewPort.height;
			}
		}
		
		public static function deleteScene(key:String):void
		{
			if(_sceneDic == null || _sceneDic[key] == null)
				return;
			
			_sceneDic[key] = null
			delete _sceneDic[key];
		}
		
		public static function switchScene(key:String, data:Object = null):void
		{
			if(_sceneDic == null || _sceneDic[key] == null)
				return;
			if(Trolling.current.currentScene != null)
			{
				Trolling.current.currentScene.visible = false;
				SoundManager.dispose();
				Trolling.current.currentScene.dispose();
				Trolling.current.currentScene.dispatchEvent(new TrollingEvent(TrollingEvent.END_SCENE));
			}
			Trolling.current.currentScene = _sceneDic[key];
			Trolling.current.currentScene.visible = true;
			Trolling.current.currentScene.data = Copy.clone(data);
			Trolling.current.currentScene.dispatchEvent(new TrollingEvent(TrollingEvent.START_SCENE));
		}
		
		public static function restartScene(sceneClass:Class, key:String, data:Object = null):void
		{
			if (!sceneClass || !key)
				return;
			
			deleteScene(key);
			addScene(sceneClass, key);
			switchScene(key, data);
		}
	}
}