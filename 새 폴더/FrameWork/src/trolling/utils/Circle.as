package trolling.utils
{
	import flash.geom.Point;

	public class Circle
	{
		public var center:Point;
		public var radius:Number;
		
		public function Circle(center:Point, radius:Number)
		{
			this.center = center;
			this.radius = radius
		}
		
		/**
		 * Circle이 특정 Point를 포함하는지 여부를 검사합니다. 
		 * @param point 검사 대상 Point입니다.
		 * @return 포함 여부를 반환합니다.
		 * 
		 */
		public function containsPoint(point:Point):Boolean
		{
			var dx:Number = this.center.x - point.x;
			var dy:Number = this.center.y - point.y;
			var distance:Number = Math.sqrt(dx * dx + dy * dy);
			
			return (distance <= this.radius)? true : false;
		}
		
		/**
		 * Circle 간의 충돌 여부를 검사합니다. 
		 * @param object 충돌 검사 대상 Circle입니다.
		 * @return 충돌 여부를 반환합니다.
		 * 
		 */
		public function intersects(object:Circle):Boolean
		{
			var dx:Number = this.center.x - object.center.x;
			var dy:Number = this.center.y - object.center.y;
			var distance:Number = Math.sqrt(dx * dx + dy * dy);

			return (distance <= this.radius + object.radius)? true : false
		}
	}
}