package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;

	/**
	 * ScreenEnd
	 *
	 * Copyright (C) 2014, Twisted Words, LLC
	 *
	 * @author Tony Tyson (teesquared@twistedwords.net)
	 */
	public class ScreenEnd extends Screen
	{
		//private var textYouWin:MovieClip;
		//private var textYouLose:MovieClip;

		private var soundLose:Sound = new SoundLose() as Sound;
		private var soundWin:Sound = new SoundWin() as Sound;

		/**
		 * ScreenEnd
		 */
		public function ScreenEnd()
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

			textYouWin.visible = ocs.youWin;
			textYouLose.visible = !ocs.youWin;

			if (ocs.youWin)
				soundWin.play();
			else
				soundLose.play();
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
