package
{
	import fl.motion.easing.Linear;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * Organ
	 *
	 * Copyright (C) 2014, Twisted Words, LLC
	 *
	 * @author Tony Tyson (teesquared@twistedwords.net)
	 */
	public class Organ extends MovieClip
	{
		private var tweenX:Tween = null;
		private var tweenY:Tween = null;

		public var row:uint = 0;
		public var col:uint = 0;

		public var targetRow:uint = 0;
		public var targetCol:uint = 0;

		public var matched:Boolean = false;

		private var finishedCallback:Function = null;

		/**
		 * Organ
		 */
		public function Organ()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		/**
		 * init
		 *
		 * @param	e
		 */
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			tweenX = new Tween(this, "x", Linear.easeOut, x, x, 0);
			tweenX.stop();

			tweenY = new Tween(this, "y", Linear.easeOut, y, y, 0);
			tweenY.stop();

			hitArea = new Sprite();

			hitArea.graphics.beginFill(0);
			hitArea.graphics.drawRect(0, 0, 80, 80);
			hitArea.graphics.endFill();

			hitArea.mouseEnabled = false;
			hitArea.visible = false; // true

			addChildAt(hitArea, 0);

			tweenX.addEventListener(TweenEvent.MOTION_FINISH, handleTweenXFinished);
			tweenY.addEventListener(TweenEvent.MOTION_FINISH, handleTweenYFinished);
		}

		/**
		 * handleTweenXFinished
		 *
		 * @param	e
		 */
		private function handleTweenXFinished(e:TweenEvent):void
		{
			if (finishedCallback != null)
			{
				var f:Function = finishedCallback;
				finishedCallback = null;
				f(this); // ha ha
			}
		}

		/**
		 * handleTweenYFinished
		 *
		 * @param	e
		 */
		private function handleTweenYFinished(e:TweenEvent):void
		{
			if (finishedCallback != null)
			{
				var f:Function = finishedCallback;
				finishedCallback = null;
				f(this); // ha ha
			}
		}

		/**
		 * setTargetX
		 *
		 * @param	x
		 * @param	duration
		 */
		public function setTargetX(x:int, duration:Number = 30.0, finishedCallback:Function = null):void
		{
			tweenX.begin = this.x;
			tweenX.finish = x;
			tweenX.duration = duration;

			if (this.finishedCallback == null)
				this.finishedCallback = finishedCallback;

			tweenX.start();
		}

		/**
		 * setTargetY
		 *
		 * @param	y
		 * @param	duration
		 */
		public function setTargetY(y:int, duration:Number = 30.0, finishedCallback:Function = null):void
		{
			tweenY.begin = this.y;
			tweenY.finish = y;
			tweenY.duration = duration;

			if (this.finishedCallback == null)
				this.finishedCallback = finishedCallback;

			tweenY.start();
		}

		/**
		 * setTargetXAndY
		 *
		 * @param	x
		 * @param	y
		 * @param	duration
		 */
		public function setTargetXAndY(x:int, y:int, duration:Number = 30.0, finishedCallback:Function = null):void
		{
			setTargetX(x, duration, finishedCallback);
			setTargetY(y, duration, finishedCallback);
		}

		/**
		 * toString
		 *
		 * @return
		 */
		override public function toString():String
		{
			return "(" + super.toString() + ", " + col + ", " + row  + ", " + x  + ", " + y  + ", " + tweenX + ", " + tweenY + ")";
		}

		/**
		 * setPosFromTarget
		 */
		public function setPosFromTarget():void
		{
			col = targetCol;
			row = targetRow;
		}
	}
}
