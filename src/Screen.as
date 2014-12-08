package
{
	import flash.display.MovieClip;
	import flash.events.Event;

	/**
	 * Screen
	 *
	 * Copyright (C) 2014, Twisted Words, LLC
	 *
	 * @author Tony Tyson (teesquared@twistedwords.net)
	 */
	public class Screen extends MovieClip
	{
		protected var ocs:OrganCrushSaga;

		public function Screen()
		{
			ocs = parent as OrganCrushSaga;

			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		protected function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
}
