package trolling.object
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import trolling.component.Component;
	import trolling.component.ComponentType;
	import trolling.component.DisplayComponent;
	import trolling.component.animation.Animator;
	import trolling.component.physics.Collider;
	import trolling.core.Disposer;
	import trolling.core.Trolling;
	import trolling.event.TrollingEvent;
	import trolling.rendering.BatchData;
	import trolling.rendering.Painter;
	import trolling.rendering.TriangleData;
	import trolling.utils.Circle;
	import trolling.utils.PivotType;
	
	public class GameObject extends EventDispatcher
	{	
		//change
		private const TAG:String = "[GameObject]";
		private const NONE:String = "none";
		
		private var _tag:String;
		
		private var _parent:GameObject = null;
		private var _depth:Number;
		
		private var _components:Dictionary;
		private var _children:Vector.<GameObject> = new Vector.<GameObject>();
		
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		private var _pivot:String;
		private var _width:Number;
		private var _height:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var _rotate:Number;
		private var _name:String;
		private var _alpha:Number;
		
		private var _red:Number;
		private var _green:Number;
		private var _blue:Number;
		
		private var _active:Boolean;
		private var _visible:Boolean;
		private var _colliderRender:Boolean;
		
		public function GameObject()
		{
			this.addEventListener(TrollingEvent.ENTER_FRAME, onThrowEvent);
			this.addEventListener(TrollingEvent.END_SCENE, onThrowEvent);
			this.addEventListener(TrollingEvent.START_SCENE, onThrowEvent);
			_x = _y = _z = _width = _height = _rotate = 0.0;
			_pivot = PivotType.TOP_LEFT;
			_scaleX = _scaleY = _alpha = _red = _green = _blue = 1;
			_components = new Dictionary();
			_active = true;
			_visible = true;
			_tag = null;
		}
		
		/**
		 *컴포넌트를 추가시켜주는 함수
		 * 추가시킬 컴포넌트를 인자로 받습니다. 
		 * @param component
		 * 
		 */		
		public function addComponent(component:Component):void
		{
			if(_components && _components[component.type])
			{
				trace(_components);
				trace(_components[component.type]);
				trace(TAG + " addComponent : GameObject already has the component of this type.");
				return;
			}
			if(component.parent != null)
				component.parent.removeComponent(component.type);
			
			if (!_components)
			{
				_components = new Dictionary();
			}
			component.parent = this;
			_components[component.type] = component;
			
			if (component is DisplayComponent)
			{
				if(DisplayComponent(component).getRenderingResource() != null)
				{
					var compare:Rectangle = new Rectangle(0, 0, DisplayComponent(component).getRenderingResource().width, DisplayComponent(component).getRenderingResource().height);
					setBound(compare);
				}
			}
		}
		
		/**
		 *컴포넌트를 삭제하는 함수
		 * 삭제시킬 컴포넌트의 타입을 인자로 받고
		 * 해당 타입의 컴포넌트가 있을경우 삭제시켜줍니다.
		 * @param componentType
		 * 
		 */		
		public function removeComponent(componentType:String):void
		{
			if(_components[componentType] == null)
				return;
			
			var component:Component = _components[componentType];
			component.dispose();
			
			delete _components[componentType];
		}
		
		/**
		 *자식을 추가시키는 함수
		 * GameObject를 인자로 받으며 오브젝트간에 트리구조를 형성할 수 있습니다. 
		 * @param child
		 * 
		 */		
		public function addChild(child:GameObject):void
		{
			if(child == null)
				return;
			if(child.parent != null)
				child.parent.removeChild(child);
			_children.insertAt(_children.length, child);
			child.parent = this;
		}
		
		/**
		 *원하는 순서로 자식오브젝트를 추가시키기위한 함수입니다. 
		 * @param child
		 * @param index
		 * 
		 */		
		public function addChildAt(child:GameObject, index:uint):void
		{
			if(child == null)
				return;
			if(_children.length < index)
				return;
			if(child.parent != null)
				child.parent.removeChild(child);
			_children.insertAt(index, child);
			child.parent = this;
		}
		
		public function setChildProperty(child:GameObject, index:uint):void
		{
			if(!_children)
				return;
			if(index >= _children.length)
				return;
			if(child == null || child.parent != this)
				return;
			removeChild(child);
			addChildAt(child, index);
		}
		
		public function switchChildsProperty(child1:GameObject, child2:GameObject):void
		{
			if(!_children)
				return;
			if(child1 == null || child2 == null)
				return;
			if((_children.indexOf(child1) < 0) || (_children.indexOf(child2) < 0))
				return;
			var child1Index:int = getChildIndex(child1);
			var child2Index:int = getChildIndex(child2);
			if(child1Index > child2Index)
			{
				addChildAt(child1, child2Index);
				addChildAt(child2, child1Index);
			}
			else
			{
				addChildAt(child2, child1Index);
				addChildAt(child1, child2Index);
			}
		}
		
		public function getChildIndex(child:GameObject):int
		{
			return _children.indexOf(child);
		}
		
		public function getChild(index:int):GameObject
		{
			if (!_children)
			{
				trace(TAG + " getChild : No children."); 
				return null;
			}
			
			if (index >= 0 && index < _children.length)
			{
				return _children[index];
			}
			else
			{
				trace(TAG + " getChild : Invalid index.");
				return null;
			}
		}
		
		/**
		 *자식오브젝트를 하나 제거합니다. 
		 * @param index
		 * 
		 */		
		public function removeChildAt(index:uint):void
		{
			if(index >= _children.length)
				return;
			_children[index].parent = null;
			_children.removeAt(index);
		}
		
		/**
		 *현제 오브젝트를 부모오브젝트로부터 삭제합니다. 
		 * 
		 */		
		public function removeFromParent():void
		{
			if(_parent == null)
				return;
			_parent.removeChild(this);
		}
		
		/**
		 *현제오브젝트가 가지고있는 모든 자식오브젝트를 삭제합니다. 
		 * 
		 */		
		public function removeChildren():void
		{
			if(_children.length <= 0)
				return;
			for(var i:int = _children.length-1; i >= 0; i--)
			{
				removeChild(_children[i]);
			}
		}
		
		/**
		 *자식오브젝트를 하나 제거합니다.
		 * @param child
		 * 
		 */		
		public function removeChild(child:GameObject):void
		{
			if(_children.indexOf(child) < 0)
				return;
			_children.removeAt(_children.indexOf(child));
			child.parent = null;
		}
		
		/**
		 *현재오브젝트를 정지합니다. 
		 * 
		 */		
		public function dispose():void
		{
			this.removeEventListener(TrollingEvent.ENTER_FRAME, onThrowEvent);
			this.removeEventListener(TrollingEvent.END_SCENE, onThrowEvent);
			this.removeEventListener(TrollingEvent.START_SCENE, onThrowEvent);
			
			Disposer.requestDisposal(this);
			
			if(_children)
			{
				for(var i:int = 0; i < _children.length; i++)
				{
					_children[i].dispose();
				}
			}
			
			if (_components)
			{
				for (var key:String in _components)
				{
					var component:Component = _components[key];
					component.dispose();
				}
			}
		}
		
		public function getChildVector():Vector.<GameObject>
		{
			var childTemp:Vector.<GameObject> = new Vector.<GameObject>();
			for(var i:int = 0; i < _children.length; i++)
				childTemp.push(_children[i]);
			childTemp.sort(sortOfZpos);
			
			return childTemp;
		}
		
		private function sortOfZpos(child1:GameObject, child2:GameObject):int
		{
			if(child1.z < child2.z)
				return 1;
			else if(child1.z == child2.z)
				return 0;
			else
				return -1;
		}
		
		/**
		 *렌더링을 하기위해서 데이터를 구축하는 함수입니다.
		 * @param painter
		 * 
		 */		
		internal function setRenderData(painter:Painter):void
		{	
			if(!_visible)
				return;
			var numChildren:int = _children.length;
			var componentType:String = decideRenderingComponent();
			var triangleData:TriangleData;
			var textureRect:Rectangle = new Rectangle(0, 0, 1, 1);
			var displayComponent:DisplayComponent = DisplayComponent(_components[componentType]);
			
			painter.pushState();
			painter.alpha *= _alpha;
			if(componentType != NONE && displayComponent.getRenderingResource() != null)
			{
				textureRect.x = displayComponent.getRenderingResource().ux;
				textureRect.y = displayComponent.getRenderingResource().vy;
				textureRect.width = displayComponent.getRenderingResource().u;
				textureRect.height = displayComponent.getRenderingResource().v;
				
				var topLeft:Vector3D = new Vector3D(0, 0, _z, 1);
				var bottomRight:Vector3D = new Vector3D(_width, _height, _z, 1);
				
				var matrix3dTemp:Matrix3D = convertMatrix(getGlobalMatrix());
				
				var perspectiveMatrix:Matrix3D = new Matrix3D();
				var vector0:Vector3D = new Vector3D(1, 0, 0, 0);
				var vector1:Vector3D = new Vector3D(0, 1, 0, 0);
				var vector2:Vector3D = new Vector3D(0, 0, 2, -2);
				var vector3:Vector3D = new Vector3D(0, 0, 1, 0);
				
				perspectiveMatrix.copyColumnFrom(0, vector0);
				perspectiveMatrix.copyColumnFrom(1, vector1);
				perspectiveMatrix.copyColumnFrom(2, vector2);
				perspectiveMatrix.copyColumnFrom(3, vector3);
				
//				trace("perspectiveMatrix = " + perspectiveMatrix.rawData);
				
//				var matrix3dTemp:Matrix3D = new Matrix3D();
//				matrix3dTemp.identity();
//				
//				var matrix3d:Matrix3D = convertMatrix(getMatrix());
//				
////				matrix3d.append(painter.matrix3d);
//				
//				matrix3dTemp.append(matrix3d);
//				matrix3dTemp.append(painter.matrix3d);
				
//				painter.matrix3d.append(matrix3d);
				
//				if(this.name == "test")
//				{
//					trace(matrix3dTemp.rawData);
//				}
				matrix3dTemp.appendScale((2/painter.viewPort.width), (2/painter.viewPort.height), 1);
				matrix3dTemp.appendRotation(-90, Vector3D.Z_AXIS);
				matrix3dTemp.appendTranslation(-1, 1, 0);
//				matrix3dTemp.append(perspectiveMatrix);
//				perspectiveMatrix.prepend(matrix3dTemp);
//				if(this.name == "test")
//				{
//					trace(matrix3dTemp.rawData);
//					trace("pretopLeft = " + topLeft);
//					trace("preBottomRight = " + bottomRight);
//				}
//				topLeft = matrix3d.transformVector(topLeft);
//				bottomRight = matrix3d.transformVector(bottomRight);
				topLeft = matrix3dTemp.transformVector(topLeft);
				bottomRight = matrix3dTemp.transformVector(bottomRight);
				
//				topLeft = matrix3dTemp.deltaTransformVector(topLeft);
//				bottomRight = matrix3dTemp.deltaTransformVector(bottomRight);
				if(this.name == "test")
				{
//					trace(perspectiveMatrix.rawData);
//					trace("pretopLeft = " + topLeft);
//					trace("preBottomRight = " + bottomRight);
				}
				
//				topLeft = perspectiveMatrix.transformVector(topLeft);
//				bottomRight = perspectiveMatrix.transformVector(bottomRight);
//				topLeft = perspectiveMatrix.transformVector(topLeft);
//				bottomRight = perspectiveMatrix.transformVector(bottomRight);
				if(this.name == "test")
				{
//					trace("topLeft = " + topLeft);
//					trace("BottomRight = " + bottomRight);
				}
				
				triangleData = new TriangleData();
				
				triangleData.rawVertexData = triangleData.rawVertexData.concat(Vector.<Number>([topLeft.x, topLeft.y, _z, textureRect.x, textureRect.y, _red, _green, _blue, painter.alpha]));
				triangleData.rawVertexData = triangleData.rawVertexData.concat(Vector.<Number>([bottomRight.x, topLeft.y, _z, textureRect.x+textureRect.width, textureRect.y, _red, _green, _blue, painter.alpha]));
				triangleData.rawVertexData = triangleData.rawVertexData.concat(Vector.<Number>([bottomRight.x, bottomRight.y, _z, textureRect.x+textureRect.width, textureRect.y+textureRect.height, _red, _green, _blue, painter.alpha]));
				triangleData.rawVertexData = triangleData.rawVertexData.concat(Vector.<Number>([topLeft.x, bottomRight.y, _z, textureRect.x, textureRect.y+textureRect.height, _red, _green, _blue, painter.alpha]));
				
				if(painter.currentBatchData == null || painter.currentBatchData.batchTexture != displayComponent.getRenderingResource().nativeTexture)
				{
					var batchData:BatchData = new BatchData();
					batchData.batchTexture = displayComponent.getRenderingResource().nativeTexture;
					painter.currentBatchData = batchData;
					painter.batchDatas.push(batchData);
				}
				painter.currentBatchData.batchTriangles.push(triangleData);
			}
			for(var i:int = 0; i < numChildren; i++)
			{
				var child:GameObject = _children[i];
				child.setRenderData(painter);
			}
			painter.popState();
		}
		
		/**
		 *렌더링에 사용될 텍스쳐이미지를 선택하는 함수입니다. 
		 * @return 
		 * 
		 */		
		private function decideRenderingComponent():String
		{
			// 컴포넌트가 없음
			if (!_components)
			{
				return NONE;
			}
				// Image만 있음
			else if (_components[ComponentType.IMAGE] && !_components[ComponentType.ANIMATOR])
			{
				var image:Component = _components[ComponentType.IMAGE];
				
				if (image.isActive)
				{
					return ComponentType.IMAGE;
				}
				else
				{
					return NONE;
				}
			}
				// Animator만 있음
			else if (!_components[ComponentType.IMAGE] && _components[ComponentType.ANIMATOR])
			{
				var animator:Component = _components[ComponentType.ANIMATOR];
				
				if (animator.isActive)
				{
					return ComponentType.ANIMATOR;
				}
				else
				{
					return NONE;
				}
			}
				// Image와 Animator 둘 다 있음
			else if (_components[ComponentType.IMAGE] && _components[ComponentType.ANIMATOR])
			{
				image = _components[ComponentType.IMAGE];
				animator = _components[ComponentType.ANIMATOR];
				
				if (image.isActive && !animator.isActive)
				{
					return ComponentType.IMAGE;
				}
				else if (!image.isActive && animator.isActive)
				{
					return ComponentType.ANIMATOR;
				}
				else if (image.isActive && animator.isActive)
				{
					return ComponentType.ANIMATOR; // Animator를 우선하여 그림
				}
				else
				{
					return NONE;
				}
			}
				// 컴포넌트가 없음
			else
			{
				return NONE;
			}
		}
		
		/**
		 *애니메이터에게 지정상태로 전이하도록 합니다. 
		 * @param nextStateName
		 * 
		 */		
		public function transition(nextStateName:String):void // [혜윤] 애니메이터에게 지정 상태로 전이하도록 합니다.
		{
			if (!_components || !_components[ComponentType.ANIMATOR])
			{
				return;
			}
			
			var animator:Animator = _components[ComponentType.ANIMATOR];
			animator.transition(nextStateName);
		}
		
		/**
		 *클릭된 좌표의 가장 위쪽에 있는 객체를 찾아냅니다. 
		 * @param point
		 * @return 
		 * 
		 */		
		public function findClickedGameObject(point:Point):GameObject
		{
			var childrenTemp:Vector.<GameObject> = getChildVector();
			var j:int;
			var k:int;
			
			var target:GameObject = null;
			for(var i:int = childrenTemp.length-1; i >= 0; i--)
			{
				if(childrenTemp[i].getBound().containsPoint(point) && childrenTemp[i].visible && childrenTemp[i].z >= 0 && childrenTemp[i].z <= 1)
				{
					target = childrenTemp[i].findClickedGameObject(point);
					break;
				}
			}
			if(target == null && getGlobalRect2().containsPoint(point))
			{
				target = this;
			}
			else if(target != null)
			{
				if(target.z > this.z && this != Trolling.current.currentScene)
					target = this;
			}
			return target;
		}
		
		/**
		 *객체의 x,y,width,height값을 받아옵니다. 
		 * @return 
		 * 
		 */		
		public function getRectangle():Rectangle
		{
			var rectangle:Rectangle = new Rectangle(_x, _y, _width, _height);
			return rectangle;
		}
		
		/**
		 *프레임워크 전체에 알려줘야하는 이벤트들은 해당 함수를 사용해서 알려줍니다.
		 * @param event
		 * 
		 */		
		private function onThrowEvent(event:TrollingEvent):void
		{
			if (!_active)
			{
				return;	
			}
			
			for(var key:String in _components)
			{
				if(_components[key] != null)
					Component(_components[key]).dispatchEvent(new TrollingEvent(event.type));
			}
			
			if(_children)
			{
				for(var i:int = 0; i < _children.length; i++)
					_children[i].dispatchEvent(new TrollingEvent(event.type));
			}
		}
		
		/**
		 *Object가 크기가 정해져있지 않을 때 이미지가 들어오면 해당 이미지의 크기로 이미지를 자동으로 늘려줍니다.
		 * @param compare
		 * 
		 */		
		private function setBound(compare:Rectangle):void
		{
			if(_width == 0)
				_width = compare.x+compare.width;
			if(_height == 0)
				_height = compare.y+compare.height;
		}
		
		//		/**
		//		 *객체가 전체좌표에서 가지는 x,y값을 구합니다. 
		//		 * @return 
		//		 * 
		//		 */		
		//		public function getGlobalPoint():Point
		//		{
		//			var matrix:Matrix3D = getGlobalMatrix();
		//			var globalPoint:Point = new Point();
		//			
		//			globalPoint.x = matrix.position.x;
		//			globalPoint.y = matrix.position.y;
		//			
		//			if(_pivot == PivotType.CENTER)
		//			{
		//				globalPoint.x -= ((_width*getGlobalScaleX())/2);
		//				globalPoint.y -= ((_height*getGlobalScaleY())/2);
		//			}
		//			
		//			return globalPoint;
		//		}
		
		/**
		 *전체좌표계에서 이 오브젝트가 차지하는 사각형을 구할 수 있습니다. 
		 * @return 
		 * 
		 */	
		public function getGlobalRect2():Rectangle
		{
			var rect:Rectangle = new Rectangle();
			//			var matrix:Matrix3D = new Matrix3D();
			//			
			//			matrix = getMatrix(matrix);
			//			if(_pivot == PivotType.CENTER)
			//				matrix.appendTranslation(-_width/2, -_height/2, 0);
			
			//			var topLeft:Vector3D = getTopLeft();
			//			var bottomRight:Vector3D = getBottomRight();
			
			var topLeft:Point = getTopLeft();
			var bottomRight:Point = getBottomRight();
			
			//			topLeft = matrix.transformVector(topLeft);
			//			bottomRight = matrix.transformVector(bottomRight);
			
			//			rect.topLeft.x = topLeft.x;
			//			rect.topLeft.y = topLeft.y;
			//			rect.bottomRight.x = bottomRight.x;
			//			rect.bottomRight.y = bottomRight.y;
			rect.topLeft = topLeft;
			rect.bottomRight = bottomRight;
			
			//			rect.size = bottomRight;
			
			return rect;
		}
		
		public function getGlobalPoint():Point
		{
			//			var point:Point = new Point();
			//			var topLeft:Vector3D = getTopLeft();
			//			
			//			point.x = topLeft.x;
			//			point.y = topLeft.y;
			
			var point:Point = getTopLeft();
			
			return point;
		}
		
		public function getBottomRight():Point
		{
			//			var matrix:Matrix3D = new Matrix3D();
			//			if(_pivot == PivotType.CENTER)
			//				matrix.prependTranslation(-_width/2, -_height/2, 0);
			//			matrix = getMatrix3d(matrix);
			//			
			//			var bottomRight:Vector3D = new Vector3D(_width, _height, _z, 0);
			//			bottomRight = matrix.transformVector(bottomRight);
			
			var matrix:Matrix = getGlobalMatrix();
			
			var bottomRight:Point = new Point(_width, _height);
			bottomRight = matrix.transformPoint(bottomRight);
			
			return bottomRight;
		}
		
		public function getTopLeft():Point
		{
			//			var matrix:Matrix3D = new Matrix3D();
			//			if(_pivot == PivotType.CENTER)
			//				matrix.prependTranslation(-_width/2, -_height/2, 0);
			//			matrix = getMatrix3d(matrix);
			//			
			//			var topLeft:Vector3D = new Vector3D(0, 0, _z, 0);
			//			topLeft = matrix.transformVector(topLeft);
			
			var matrix:Matrix = getGlobalMatrix();
			
			//			trace(matrix.toString());
			
			var topLeft:Point = new Point(0,0);
			topLeft = matrix.transformPoint(topLeft);
			
			return topLeft;
		}
		
		public function getMatrix():Matrix
		{
			var matrix:Matrix = new Matrix();
			if(_pivot == PivotType.CENTER)
				matrix.translate(-_width/2, -_height/2);
			
			matrix.scale(_scaleX, _scaleY);
			matrix.translate(_x, _y);
			matrix.rotate(_rotate);
			
			return matrix;
		}
		
		public function getGlobalMatrix():Matrix
		{
			var matrix:Matrix = new Matrix();
			
			matrix = calculMatrix(matrix);
			
			if(_pivot == PivotType.CENTER)
				matrix.translate(-_width/2, -_height/2);
			
			return matrix;
		}
		
		public function calculMatrix(matrix:Matrix):Matrix
		{
			matrix.scale(_scaleX, _scaleY);
			matrix.translate(_x, _y);
			matrix.rotate(_rotate);
			
			if(_parent != null)
				matrix = _parent.calculMatrix(matrix);
			
			return matrix;
		}
		
		public function getGlobalMatrix3d():Matrix3D
		{
			var matrix:Matrix = getGlobalMatrix();
			var matrix3d:Matrix3D = convertMatrix(matrix);
			
			return matrix3d;
		}
		
		private function convertMatrix(matrix:Matrix):Matrix3D
		{
			var matrix3d:Matrix3D = new Matrix3D();
			var vector0:Vector3D = new Vector3D(matrix.a, 0, 0, 0);
			var vector1:Vector3D = new Vector3D(0, matrix.d, 0, 0);
			var vector2:Vector3D = new Vector3D(0, 0, 1, 0);
			var vector3:Vector3D = new Vector3D(matrix.tx, matrix.ty, 0, 0);
			
			matrix3d.copyColumnFrom(0, vector0);
			matrix3d.copyColumnFrom(1, vector1);
			matrix3d.copyColumnFrom(2, vector2);
			matrix3d.copyColumnFrom(3, vector3);
			
			return matrix3d;
		}
		
		//		public function getMatrix3d(matrix:Matrix3D):Matrix3D
		//		{
		//			if(_parent != null)
		//				matrix = _parent.getMatrix3d(matrix);
		//			
		//			matrix.prependTranslation(_x, _y, _z);
		//			matrix.prependRotation(_rotate, Vector3D.Z_AXIS);
		//			matrix.prependScale(_scaleX, _scaleY, 1);
		//			
		//			return matrix;
		//		}
		
//		/**
//		 *객체의 전체좌표를 구할 때 사용할 행렬을 반환합니다.
//		 * @return 
//		 * 
//		 */		
//		private function getGlobalMatrix():Matrix3D
//		{
//			var matrix:Matrix3D = new Matrix3D();
//			matrix.identity();
//			
//			setGlobalMatrix(matrix);
//			
//			return matrix;
//		}
		
//		/**
//		 *객체의 전체좌표를 구할 때 사용할 행렬을 계산합니다.
//		 * @param matrix
//		 * @return 
//		 * 
//		 */		
//		private function setGlobalMatrix(matrix:Matrix3D):void
//		{
//			var drawRect:Rectangle = getRectangle();
//			
//			if(_parent != null)
//				_parent.setGlobalMatrix(matrix);
//			
//			matrix.prependTranslation((drawRect.x), (drawRect.y), 0);
//			matrix.prependRotation(_rotate, Vector3D.Z_AXIS);
//			matrix.prependScale(_scaleX/(1+_z), _scaleY/(1+_z), 1);
//		}
		
		/**
		 *객체가 최종적으로 나타내는 X의 스케일값을 반환합니다.
		 * @return 
		 * 
		 */		
		public function getGlobalScaleX():Number
		{
			var scaleX:Number;
			scaleX = _scaleX;
			
			if(_parent != null)
			{
				scaleX *= _parent.getGlobalScaleX();
			}
			
			return scaleX;
		}
		
		/**
		 *객체가 최종적으로 나타내는 Y의 스케일값을 반환합니다. 
		 * @return 
		 * 
		 */		
		public function getGlobalScaleY():Number
		{
			var scaleY:Number;
			scaleY = _scaleY;
			
			if(_parent != null)
			{
				scaleY *= _parent.getGlobalScaleY();
			}
			
			return scaleY;
		}
		
		/**
		 *Object와 Children까지 모두 합하여 범위를 구합니다.
		 * @return 
		 * 
		 */		
		public function getBound():Rectangle
		{
			var bound:Rectangle = getGlobalRect2();
			var numChildren:int = _children.length;
			
			for(var i:int = 0; i < numChildren; i++)
			{
				var childBound:Rectangle = _children[i].getBound();
				if(childBound.topLeft.x < bound.topLeft.x)
				{
					bound.width += (bound.x - childBound.x);
					bound.x = childBound.x;
				}
				if(childBound.topLeft.y < bound.topLeft.y)
				{
					bound.height += (bound.y - childBound.y);
					bound.y = childBound.y;
				}
				if(childBound.bottomRight.x > bound.bottomRight.x)
					bound.width += (childBound.bottomRight.x-bound.bottomRight.x);
				if(childBound.bottomRight.y > bound.bottomRight.y)
					bound.height += (childBound.bottomRight.y-bound.bottomRight.y);
			}
			return bound;
		}
		
		//		public function getBound():Rectangle
		//		{
		//			var bound:Rectangle = getGlobalRect();
		//			var numChildren:int = _children.length;
		//			
		//			for(var i:int = 0; i < numChildren; i++)
		//			{
		//				var childBound:Rectangle = _children[i].getBound();
		//				if(childBound.topLeft.x < bound.topLeft.x)
		//				{
		//					bound.width += (bound.x - childBound.x);
		//					bound.x = childBound.x;
		//				}
		//				if(childBound.topLeft.y < bound.topLeft.y)
		//				{
		//					bound.height += (bound.y - childBound.y);
		//					bound.y = childBound.y;
		//				}
		//				if(childBound.bottomRight.x > bound.bottomRight.x)
		//					bound.width += (childBound.bottomRight.x-bound.bottomRight.x);
		//				if(childBound.bottomRight.y > bound.bottomRight.y)
		//					bound.height += (childBound.bottomRight.y-bound.bottomRight.y);
		//			}
		//			return bound;
		//		}
		
		//		/**
		//		 *전체좌표계에서 이 오브젝트가 차지하는 사각형을 구할 수 있습니다. 
		//		 * @return 
		//		 * 
		//		 */		
		//		private function getGlobalRect():Rectangle
		//		{
		//			var rect:Rectangle = new Rectangle();
		//			rect.topLeft = getGlobalPoint();
		//			rect.width = _width*getGlobalScaleX();
		//			rect.height = _height*getGlobalScaleY();
		//			
		//			return rect;
		//		}
		
		/**
		 * 
		 * @param red
		 * @param green
		 * @param blue
		 * 게임오브젝트에 색상을 블렌딩 합니다. 
		 */
		public function blendColor(red:Number, green:Number, blue:Number):void
		{
			_red = red;
			_green = green;
			_blue = blue;
		}
		
		/**
		 *true면 콜라이더가 랜더링됩니다. 
		 */
		public function get colliderRender():Boolean
		{
			return _colliderRender;
		}
		
		/**
		 * @private
		 */
		public function set colliderRender(value:Boolean):void
		{
			_colliderRender = value;
		}
		
		public function get components():Dictionary
		{
			return _components;
		}
		
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void
		{
			_visible = value;
			
			for(var componentType:String in _components)
			{
				var component:Component = _components[componentType];
				component.isActive = value;
			}
		}
		
		public function get rotate():Number
		{
			return _rotate;
		}
		
		public function set rotate(value:Number):void
		{
			_rotate = value;
		}
		
		public function get parent():GameObject
		{
			return _parent;
		}
		
		public function set parent(value:GameObject):void
		{
			_parent = value;
		}
		
		public function get height():Number
		{
			return _height;
		}
		
		public function set height(value:Number):void
		{
			_height = value;
		}
		
		public function get width():Number
		{
			return _width;
		}
		
		public function set width(value:Number):void
		{
			_width = value;
		}
		
		public function get z():Number
		{
			return _z;
		}
		
		public function set z(value:Number):void
		{
			if(value > 1)
				value = 1;
			else if(value < 0)
				value = 0;
			_z = value;
		}
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(value:Number):void
		{
			_y = value;
		}
		
		public function get x():Number
		{
			return _x;
		}
		
		public function set x(value:Number):void
		{
			_x = value;
		}
		
		public function get scaleY():Number
		{
			return _scaleY;
		}
		
		public function set scaleY(value:Number):void
		{
			_scaleY = value;
		}
		
		public function get scaleX():Number
		{
			return _scaleX;
		}
		
		public function set scaleX(value:Number):void
		{
			_scaleX = value;
		}
		
		public function get pivot():String
		{
			return _pivot;
		}
		
		public function set pivot(value:String):void
		{
			if(value != PivotType.CENTER && value != PivotType.TOP_LEFT)
				return;
			_pivot = value;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get alpha():Number
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void
		{
			_alpha = value;
		}
		
		public function get blue():Number
		{
			return _blue;
		}
		
		public function set blue(value:Number):void
		{
			_blue = value;
		}
		
		public function get green():Number
		{
			return _green;
		}
		
		public function set green(value:Number):void
		{
			_green = value;
		}
		
		public function get red():Number
		{
			return _red;
		}
		
		public function set red(value:Number):void
		{
			_red = value;
		}
		
		public function get tag():String
		{
			return _tag;
		}
		
		public function set tag(value:String):void
		{
			_tag = value;
		}
		
		public function get active():Boolean
		{
			return _active;
		}
		
		public function set active(value:Boolean):void
		{
			_active = value;
			
			for(var componentType:String in _components)
			{
				var component:Component = _components[componentType];
				component.isActive = value;
			}
		}
	}
}

