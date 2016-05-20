package trolling.component
{
	import trolling.rendering.Texture;
	
	public class DisplayComponent extends Component
	{
		public function DisplayComponent(type:String)
		{
			super(type);
		}
		
		/**
		 *컴포넌트가 가지고있는 렌더링리소스를 반환합니다.
		 * @return 
		 * 
		 */		
		public virtual function getRenderingResource():Texture
		{
			return null;
		}
	}
}