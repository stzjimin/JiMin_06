package Trolling.Object
{
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import Trolling.Rendering.Painter;

	public class DisplayObject extends EventDispatcher
	{
		private var _parent:DisplayObject = null;
		private var _depth:Number;
		
		private var _propertys:Dictionary;
		private var _children:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		
		private var _x:Number;
		private var _y:Number;
		private var _pivotX:Number;
		private var _pivotY:Number;
		private var _width:Number;
		private var _height:Number;
		
		private var _color:uint;
		private var _bitmapData:BitmapData;
		private var _texture:Texture;
		
		public function DisplayObject()
		{
			_x = _y = _pivotX = _pivotY = _width = _height = 0.0;
			_propertys = new Dictionary();
		}
		
		public function setColor(color:uint):void
		{
			_color = color;
			_bitmapData = new BitmapData(_width, _height, false, _color);
		}

		public function addComponent(property:Property):void
		{
			if(_propertys[property.type] == null)
				_propertys[property.type] = new Vector.<Property>();
			
			_propertys[property.type].insertAt(_propertys[property.type].length, property);
		}
		
		public function addChild(child:DisplayObject):void
		{
			if(_children == null)
				_children = new Vector.<DisplayObject>();
			_children.insertAt(_children.length, child);
			if(child != null)
				child.parent = this;
		}
		
		public function render(painter:Painter):void
		{	
			_depth = 0;
			painter.triangleData.initArray();
			var numChildren:int = _children.length;
			
			for(var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = _children[i];
				child.render(painter);
			}
			
			trace("numChildren = " + numChildren);
			var rect:Rectangle = getRectangle();
			var globalPoint:Point = getGlobalPoint();
			
			rect.x = globalPoint.x;
			rect.y = globalPoint.y;
			
			rect.x = (rect.x - (painter.viewPort.width/2)) / (painter.viewPort.width/2);
			rect.y = ((painter.viewPort.height/2) - rect.y) / (painter.viewPort.height/2);
			
			rect.width = rect.width / (painter.viewPort.width/2);
			rect.height = rect.height / (painter.viewPort.height/2);
			trace(rect);
			
			var triangleIndex:Vector.<uint> = new Vector.<uint>();
			
			var triangleStartIndex:uint = painter.triangleData.vertexData.length;
//			if(painter.root == this)
//			{
//				painter.triangleData.vertexData.push(Vector.<Number>([rect.x+rect.width, rect.y, 0, 1, 0, 0]));
//				painter.triangleData.vertexData.push(Vector.<Number>([rect.x+rect.width, rect.y-rect.height, 0, 0, 0, 1]));
//				painter.triangleData.vertexData.push(Vector.<Number>([rect.x, rect.y-rect.height, 0, 0, 1, 0]));
//				painter.triangleData.vertexData.push(Vector.<Number>([rect.x, rect.y, 0, 0, 0, 0]));
//				
//				triangleIndex.push(triangleStartIndex);
//				triangleIndex.push(triangleStartIndex+1);
//				triangleIndex.push(triangleStartIndex+2);
//				painter.triangleData.indexData.push(triangleIndex);
//				
//				triangleIndex = new Vector.<uint>();
//				triangleIndex.push(triangleStartIndex+2);
//				triangleIndex.push(triangleStartIndex+3);
//				triangleIndex.push(triangleStartIndex);
//				painter.triangleData.indexData.push(triangleIndex);
//				
//				painter.setProgram();
//				painter.triangleData.initData();
//				painter.createVertexBuffer(1);
//				painter.createIndexBuffer();
//				painter.setVertextBuffer(1);
//				painter.setMatrix();
//				
//			//	painter.draw();
//			}
			if(painter.root != this)
			{
				trace("_width , _height = " + _width + ", " + _height);
				_texture = painter.context.createTexture(_width, _height, Context3DTextureFormat.BGRA, false);
				_texture.uploadFromBitmapData(_bitmapData);
				painter.context.setTextureAt(0, _texture);
			
				painter.triangleData.vertexData.push(Vector.<Number>([rect.x+rect.width, rect.y, 0, 1, 0]));
				painter.triangleData.vertexData.push(Vector.<Number>([rect.x+rect.width, rect.y-rect.height, 0, 1, 1]));
				painter.triangleData.vertexData.push(Vector.<Number>([rect.x, rect.y-rect.height, 0, 0, 1]));
				painter.triangleData.vertexData.push(Vector.<Number>([rect.x, rect.y, 0, 0, 0]));
				
				triangleIndex.push(triangleStartIndex);
				triangleIndex.push(triangleStartIndex+1);
				triangleIndex.push(triangleStartIndex+2);
				painter.triangleData.indexData.push(triangleIndex);
				
				triangleIndex = new Vector.<uint>();
				triangleIndex.push(triangleStartIndex+2);
				triangleIndex.push(triangleStartIndex+3);
				triangleIndex.push(triangleStartIndex);
				painter.triangleData.indexData.push(triangleIndex);
				
				painter.setProgram();
				painter.triangleData.initData();
				painter.createVertexBuffer(1);
				painter.createIndexBuffer();
				painter.setVertextBuffer(1);
				painter.setMatrix();
				
				painter.draw();
			}
		}
		
		public function getGlobalPoint():Point
		{
			var globalPoint:Point = new Point(_x, _y);
			
			var searchObject:DisplayObject = this;
			while(searchObject.parent != null)
			{
				globalPoint.x += searchObject.parent.x;
				globalPoint.y += searchObject.parent.y;
				
				searchObject = searchObject.parent;
			}
			
			trace(globalPoint);
			return globalPoint;
		}
		
		public function getRectangle():Rectangle
		{
			var rectangle:Rectangle = new Rectangle(_x, _y, _width, _height);
			return rectangle;
		}
		
		public function get parent():DisplayObject
		{
			return _parent;
		}
		
		public function set parent(value:DisplayObject):void
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
	}
}