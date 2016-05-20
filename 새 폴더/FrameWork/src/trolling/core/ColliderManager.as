package trolling.core
{
	import trolling.component.physics.Collider;
	import trolling.event.TrollingEvent;
	
	internal class ColliderManager
	{
		private const TAG:String = "[ColliderManager]";
		
		private var _colliders:Vector.<Collider>;
		
		public function ColliderManager()
		{
			
		}
		
		/**
		 * ColliderManager에 Collider를 등록합니다. 
		 * @param collider 등록하고자 하는 Collider입니다.
		 * 
		 */
		public function addCollider(collider:Collider):void
		{
			if (!_colliders)
			{
				_colliders = new Vector.<Collider>();
			}
			_colliders.push(collider);
		}
		
		/**
		 * ColliderManager에서 Collider를 제거합니다. 
		 * @param collider 제거하고자 하는 Collider입니다.
		 * 
		 */
		public function removeCollider(collider:Collider):void
		{
			if (!_colliders || !collider)
			{
				return;
			}
			
			var index:int = _colliders.indexOf(collider);
			if (index != -1)
			{
				_colliders.removeAt(index);	
			}
		}
		
		/**
		 * 등록된 Collider에 대해 충돌 검사를 수행합니다. 충돌한 Collider를 가진 GameObject에게는 충돌 대상(GameObject)에 대한 정보를 포함하는 충돌 이벤트를 dispatch합니다.
		 * 
		 */
		public function detectCollision():void
		{
			if (!_colliders || _colliders.length <= 1)
			{
				return;
			}
			
			var index:int = 0;
			var collidedIndices:Vector.<int>;
			var detectionObjects:Vector.<Collider> = new Vector.<Collider>();
			for (var i:int = 0; i < _colliders.length; i++)
			{
				detectionObjects.push(_colliders[i]);	
			}
			
			if (!detectionObjects)
			{
				throw new ArgumentError(TAG + " detectCollision : Failed to clone Colliders.");
			}
			
			while (index < detectionObjects.length - 1)
			{
				for (var j:int = index + 1; j < detectionObjects.length; j++)
				{
					var isTarget:Boolean = true;
					var ignoreTagsA:Vector.<String> = detectionObjects[index].ignoreTags;
					var ignoreTagsB:Vector.<String> = detectionObjects[j].ignoreTags;
					
					if (ignoreTagsA)
					{
						for (var k:int = 0; k < ignoreTagsA.length; k++)
						{
							if (ignoreTagsA[k] == detectionObjects[j].parent.tag)
							{
								isTarget = false;
								break;
							}
						}
					}
					
					if (isTarget && ignoreTagsB)
					{
						for (k = 0; k < ignoreTagsB.length; k++)
						{
							if (ignoreTagsB[k] == detectionObjects[index].parent.tag)
							{
								isTarget = false;
								break;
							}
						}
					}
					
					if (!isTarget)
					{
						continue;
					}
					
					if (detectionObjects[index].isCollision(detectionObjects[j]))
					{
						// Dispatch event
						detectionObjects[index].parent.dispatchEvent(
							new TrollingEvent(TrollingEvent.COLLIDE, detectionObjects[j].parent));
						detectionObjects[j].parent.dispatchEvent(
							new TrollingEvent(TrollingEvent.COLLIDE, detectionObjects[index].parent));
						
						// Store collided objects' indices for deletion from detectionObjects
						if (!collidedIndices)
						{
							collidedIndices = new Vector.<int>();
						}
						collidedIndices.push(j);
					}
				}
				
				// Remove collided objects from detectionObjects
				if (collidedIndices)
				{
					for (var l:int = collidedIndices.length - 1; l >= 0; l--)
					{
						detectionObjects.removeAt(collidedIndices[l]);
					}
				}
				collidedIndices = null;
				
				index++;
			}
			
			collidedIndices = null;
			detectionObjects = null;
		}
	}
}

