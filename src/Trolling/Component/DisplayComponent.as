package Trolling.Component
{
	import flash.display.BitmapData;
	
	import Trolling.Object.DisplayObject;

	public class DisplayComponent extends Component
	{
		public function DisplayComponent(type:String, name:String, parent:DisplayObject)
		{
			super(type, name, parent);
		}
		
		public virtual function getRenderingResource():BitmapData
		{
			return null;
		}
	}
}