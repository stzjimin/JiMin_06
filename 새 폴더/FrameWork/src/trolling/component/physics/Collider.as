package trolling.component.physics
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import trolling.component.Component;
	import trolling.component.ComponentType;
	import trolling.core.Trolling;
	import trolling.event.TrollingEvent;
	import trolling.object.GameObject;
	import trolling.utils.Circle;
	
	public class Collider extends Component
	{
		public static const ID_NONE:int = 0;
		public static const ID_RECT:int = 1;
		public static const ID_CIRCLE:int = 2;
		
		private const TAG:String = "[Collider]";
		
		private var _id:int;
		private var _rect:Rectangle;
		private var _circle:Circle;
		private var _ratioX:Number;
		private var _ratioY:Number;
		private var _ignoreTags:Vector.<String>;
		
		public function Collider()
		{
			super(ComponentType.COLLIDER);
			
			_isActive = false; // Collider는 지정된 rect 또는 circle의 위치 및 크기를 최초로 update한 후 활성화됩니다.
			
			_id = ID_NONE;
			_rect = null;
			_circle = null;
			_ratioX = 0;
			_ratioY = 0;
			_ignoreTags = null;
			
			addEventListener(TrollingEvent.ENTER_FRAME, onNextFrame);
			addEventListener(TrollingEvent.START_SCENE, onStartScene);
			addEventListener(TrollingEvent.END_SCENE, onEndScene);
		}
		
		public override function dispose():void
		{
			this.isActive = false;
			
			_id = ID_NONE;
			_rect = null;
			_circle = null;
			_ratioX = 0;
			_ratioY = 0;
			
			if (_ignoreTags)
			{
				for (var i:int = 0; i < _ignoreTags.length; i++)
				{
					_ignoreTags[i] = null;
				}
			}
			_ignoreTags = null;
			
			Trolling.current.colliderManager.removeCollider(this);
			
			super.dispose();
		}
		
		/**
		 * parent가 지정되면 소유한 rect 또는 circle의 위치 및 크기를 계산합니다. parent가 최초로 지정된 경우에만 ColliderManager에 자신을 추가합니다.
		 * @param value Collider를 소유하는 GameObject입니다.
		 * 
		 */
		public override function set parent(value:GameObject):void
		{
			var isFirst:Boolean = false;
			if (!_parent)
			{
				isFirst = true;
			}
			
			_parent = value;
			update();
			
			_isActive = true;
			
			if (isFirst)
			{
				Trolling.current.colliderManager.addCollider(this);
			}
		}
		
		/**
		 * Collider를 활성화 또는 비활성화합니다. EventListener에 대한 작업과 ColliderManager에 대한 작업을 포함합니다. 
		 * @param value
		 * 
		 */
		public override function set isActive(value:Boolean):void
		{
			if (value)
			{
				if (!_isActive)
				{
					addEventListener(TrollingEvent.ENTER_FRAME, onNextFrame);
					addEventListener(TrollingEvent.START_SCENE, onStartScene);
					addEventListener(TrollingEvent.END_SCENE, onEndScene);
					
					Trolling.current.colliderManager.addCollider(this);
				}
			}
			else
			{
				if (_isActive)
				{
					removeEventListener(TrollingEvent.ENTER_FRAME, onNextFrame);
					removeEventListener(TrollingEvent.START_SCENE, onStartScene);
					removeEventListener(TrollingEvent.END_SCENE, onEndScene);
					
					Trolling.current.colliderManager.removeCollider(this);
				}
			}
			
			_isActive = value;
		}
		
		/**
		 * 매프레임마다 update를 호출합니다.
		 * @param event TrollingEvent.ENTER_FRAME
		 * 
		 */
		protected override function onNextFrame(event:TrollingEvent):void
		{
			if (_isActive)
			{
				update();
			}
		}
		
		protected override function onStartScene(event:TrollingEvent):void
		{
			this.isActive = true;
		}
		
		protected override function onEndScene(event:TrollingEvent):void
		{
			this.isActive = false;
		}
		
		/**
		 * Collider의 타입에 따라 충돌 검사를 합니다.
		 * @param object 충돌 검사 대상인 Collider입니다.
		 * @return 충돌 여부를 반환합니다.
		 * 
		 */
		public function isCollision(object:Collider):Boolean
		{
			var objectId:int = object.id;
			
			if (_id == ID_NONE || objectId == ID_NONE)
			{
				return false;
			}
			
			switch (_id)
			{
				case ID_RECT:
				{
					if (objectId == ID_RECT)
					{
						return _rect.intersects(object.rect);
					}
					else if (objectId == ID_CIRCLE)
					{
						return detectCollisionRectToCircle(_rect, object.circle);
					}
				}
					break;
				
				case ID_CIRCLE:
				{
					if (objectId == ID_RECT)
					{
						return detectCollisionRectToCircle(object.rect, _circle);
					}
					else if (objectId == ID_CIRCLE)
					{
						return _circle.intersects(object.circle);
					}
				}
					break;
			}
			
			return false;
		}
		
		/**
		 * 사각형 충돌체를 설정합니다. parent의 크기를 기준으로 한 비율을 입력합니다. 위치는 parent의 중앙으로 자동 설정됩니다.  
		 * @param ratioX parent의 width를 기준으로 한 충돌체의 width 비율입니다.
		 * @param ratioY parent의 height를 기준으로 한 충돌체의 height 비율입니다.
		 * 
		 */
		public function setRect(ratioX:Number, ratioY:Number):void
		{
			_id = ID_RECT;
			_rect = new Rectangle();
			_ratioX = ratioX;
			_ratioY = ratioY;
		}
		
		/**
		 * 원 충돌체를 설정합니다. parent의 크기를 기준으로 한 비율을 입력합니다. 위치는 parent의 중앙으로 자동 설정됩니다.  
		 * @param ratio parent를 기준으로 한 충돌체의 지름 비율입니다.
		 * 
		 */
		public function setCircle(ratio:Number):void
		{
			_id = ID_CIRCLE;
			_circle = new Circle(new Point(0, 0), 0);
			_ratioX = ratio;
		}
		
		public function addIgnoreTag(tag:String):void
		{
			if (!tag)
			{
				return;
			}
			
			if (!_ignoreTags)
			{
				_ignoreTags = new Vector.<String>();
			}
			_ignoreTags.push(tag);
		}
		
		public function removeIgnoreTag(tag:String):void
		{
			if (!tag || !_ignoreTags)
			{
				return;
			}
			
			for (var i:int = 0; i < _ignoreTags.length; i++)
			{
				if (_ignoreTags[i] == tag)
				{
					_ignoreTags[i] = null;
					_ignoreTags.removeAt(i);
					break;
				}
			}
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function get rect():Rectangle
		{
			return _rect;
		}
		
		public function get circle():Circle
		{
			return _circle;
		}
		
		public function get ratioX():Number
		{
			return _ratioX;
		}
		
		public function set ratioX(value:Number):void
		{
			_ratioX = value;
		}
		
		public function get ratioY():Number
		{
			return _ratioY;
		}
		
		public function set ratioY(value:Number):void
		{
			_ratioY = value;
		}
		
		public function get ignoreTags():Vector.<String>
		{
			return _ignoreTags;
		}
		
		public function set ignoreTags(value:Vector.<String>):void
		{
			_ignoreTags = value;
		}
		
		/**
		 * 사각형과 원의 충돌 여부를 검사합니다. 
		 * @param rect 충돌 검사 대상인 사각형 Collider입니다.
		 * @param circle 충돌 검사 대상인 원 Collider입니다.
		 * @return 충돌 여부를 반환합니다.
		 * 
		 */
		private function detectCollisionRectToCircle(rect:Rectangle, circle:Circle):Boolean
		{
			var topRight:Point = new Point(rect.x + rect.width, rect.y);
			var bottomLeft:Point = new Point(rect.x, rect.y + rect.height);
			
			if (circle.containsPoint(rect.topLeft)) return true;
			if (circle.containsPoint(topRight)) return true;
			if (circle.containsPoint(bottomLeft)) return true;
			if (circle.containsPoint(rect.bottomRight)) return true;
			
			var outerRect:Rectangle = new Rectangle(
				circle.center.x - circle.radius, circle.center.y - circle.radius,
				circle.radius, circle.radius);
			
			return rect.intersects(outerRect);
		}
		
		/**
		 * parent 기준으로 Collider(rect 또는 circle)의 크기과 위치를 업데이트합니다. Collider의 위치는 Global 좌표입니다.
		 * 
		 */
		private function update():void
		{
			if (!_parent || _id == ID_NONE)
			{
				return;
			}
			
			var parentGlobalPos:Point = _parent.getGlobalPoint();
			var parentWidth:Number = _parent.width * _parent.getGlobalScaleX();
			var parentHeight:Number = _parent.height * _parent.getGlobalScaleY();
			
			if (_id == ID_RECT)
			{
				_rect.width = parentWidth * _ratioX;
				_rect.height = parentHeight * _ratioY;
				_rect.x = parentGlobalPos.x + (parentWidth / 2 - _rect.width / 2);
				_rect.y = parentGlobalPos.y + (parentHeight / 2 - _rect.height / 2);
			}
			else if (_id == ID_CIRCLE)
			{
				_circle.radius = parentWidth * _ratioX / 2;
				_circle.center.x = parentGlobalPos.x + parentWidth / 2;
				_circle.center.y = parentGlobalPos.y + parentHeight / 2;
			}
		}
	}
}
