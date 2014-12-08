package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * ScreenInstructions
	 *
	 * Copyright (C) 2014, Twisted Words, LLC
	 *
	 * @author Tony Tyson (teesquared@twistedwords.net)
	 */
	public class ScreenInstructions extends Screen
	{
		/**
		 * ScreenInstructions
		 */
		public function ScreenInstructions()
		{
			super();
		}

		/**
		 * init
		 *
		 * @param	e
		 */
		protected override function init(e:Event):void
		{
			super.init(e);

			buttonOk.addEventListener(MouseEvent.CLICK, handleOkClicked);
		}

		/**
		 * handleOkClicked
		 *
		 * @param	e
		 */
		private function handleOkClicked(e:MouseEvent):void
		{
			buttonOk.removeEventListener(MouseEvent.CLICK, handleOkClicked);
			ocs.play();
		}
	}
}
