package trolling.media
{
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	
	public class Sound extends flash.media.Sound
	{
		public static const INFINITE:int = -1;
		public static const NO_LOOP:int = 0;
		
		private var _volume:Number;
		private var _panning:Number;
		private var _startTime:Number;
		private var _loops:int;
		private var _channelIndex:int;
		
		public function Sound(stream:URLRequest = null, context:SoundLoaderContext = null)
		{
			super(stream, context);
			
			_volume = 1;
			_panning = 0;
			_startTime = 0;
			_loops = NO_LOOP;
			_channelIndex = -1;
		}
		
		public function dispose():void
		{
			_volume = 1;
			_panning = 0;
			_startTime = 0;
			_loops = NO_LOOP;
			_channelIndex = -1;
		}
		
		/**
		 * Sound의 음량으로 0부터 1 사이의 값입니다.
		 * @return 
		 * 
		 */
		public function get volume():Number
		{
			return _volume;
		}
		
		/**
		 * Sound의 음량으로 0부터 1 사이의 값입니다.
		 * @param value
		 * 
		 */
		public function set volume(value:Number):void
		{
			_volume = value;
		}
		
		/**
		 * Sound의 Panning을 제어하는 -1(왼쪽 최대)부터 1(오른쪽 최대) 사이의 값입니다. 기본값은 0입니다. 
		 * @return 
		 * 
		 */
		public function get panning():Number
		{
			return _panning;
		}
		
		/**
		 * Sound의 Panning을 제어하는 -1(왼쪽 최대)부터 1(오른쪽 최대) 사이의 값입니다. 기본값은 0입니다.
		 * @param value
		 * 
		 */
		public function set panning(value:Number):void
		{
			_panning = value;
		}
		
		/**
		 * Sound의 시작 시점입니다. 기본값은 0(처음부터 재생)이며 Millisecond 단위입니다. 
		 * @return 
		 * 
		 */
		public function get startTime():Number
		{
			return _startTime;
		}
		
		/**
		 * Sound의 시작 시점입니다. 기본값은 0(처음부터 재생)이며 Millisecond 단위입니다.
		 * @param value
		 * 
		 */
		public function set startTime(value:Number):void
		{
			_startTime = value;
		}
		
		/**
		 * Sound의 Loop 값입니다. 
		 * @return -1(Sound.INFINITE): 무한 반복 / 0(Sound.NO_LOOP): 1회 재생 / 1~ : 지정한 횟수만큼 재생 
		 * 
		 */
		public function get loops():int
		{
			return _loops;
		}
		
		/**
		 * Sound의 Loop 값입니다.
		 * @param value -1(Sound.INFINITE): 무한 반복 / 0(Sound.NO_LOOP): 1회 재생 / 1~ : 지정한 횟수만큼 재생
		 * 
		 */
		public function set loops(value:int):void
		{
			_loops = value;
		}
		
		/**
		 * 해당 Sound가 재생된 SoundChannel의 인덱스입니다. 재생된 적이 없다면 -1입니다. 
		 * @return 
		 * 
		 */
		public function get channelIndex():int
		{
			return _channelIndex;
		}
		
		/**
		 * 해당 Sound가 재생된 SoundChannel의 인덱스입니다. 재생된 적이 없다면 -1입니다. 
		 * @param value
		 * 
		 */
		public function set channelIndex(value:int):void
		{
			_channelIndex = value;
		}
	}
}
