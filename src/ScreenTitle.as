package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * ScreenTitle
	 *
	 * Copyright (C) 2014, Twisted Words, LLC
	 *
	 * @author Tony Tyson (teesquared@twistedwords.net)
	 */
	public class ScreenTitle extends Screen
	{
		//private var buttonStart:MovieClip;

		/**
		 * ScreenTitle
		 */
		public function ScreenTitle()
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

			buttonStart.addEventListener(MouseEvent.CLICK, handleStartClicked);
		}

		/**
		 * handleStartClicked
		 *
		 * @param	e
		 */
		private function handleStartClicked(e:MouseEvent):void
		{
			buttonStart.removeEventListener(MouseEvent.CLICK, handleStartClicked);
			ocs.play();
		}
	}
}
