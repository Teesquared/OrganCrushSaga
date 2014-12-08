package
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;
	import organTypes.*;

	/**
	 * ScreenGame
	 *
	 * Copyright (C) 2014, Twisted Words, LLC
	 *
	 * @author Tony Tyson (teesquared@twistedwords.net)
	 */
	public class ScreenGame extends Screen
	{
		private var organs:Vector.<Organ> = new Vector.<Organ>();
		private var numberOfMoves:uint = 0;

		private var randomOrganTypes:Vector.<Class> = new <Class>[
			OrganBlatter,
			OrganBrain,
			OrganEye,
			OrganHeart,
			OrganKidney,
			OrganLiver,
			OrganLungs,
			OrganTongue
		];

		private var specialOrganTypes:Vector.<Class> = new <Class>[
			OrganSpleen,
			OrganStomach
		];

		private var delayTimer:Timer = new Timer(1000, 1);

		private var swapOrganA:Organ = null;
		private var swapOrganB:Organ = null;

		private var lastMouseX:Number = 0;
		private var lastMouseY:Number = 0;

		private var allowPlayerMove:Boolean = false;

		private var hasStomach:Boolean = false;
		private var hasSpleen:Boolean = false;
		private var moveCount:uint = 0;
		private var turnsLeft:int = 0;

		private var theStomach:OrganStomach = null;
		private var theSpleen:OrganSpleen = null;

		private var soundCrush:Sound = new SoundCrush() as Sound;
		private var soundError:Sound = new SoundError() as Sound;
		private var soundNoMatch:Sound = new SoundNoMatch() as Sound;
		private var soundSpleen:Sound = new SoundSpleen() as Sound;
		private var soundStomach:Sound = new SoundStomach() as Sound;

		/*
		private var textSpleen:TextField;
		private var textStomach:TextField;
		private var textTurnsLeft:TextField;
		private var textTurns:TextField;
		*/

		/**
		 * ScreenGame
		 */
		public function ScreenGame()
		{
			super();
		}

		/**
		 * addRandomOrgan
		 *
		 * @return
		 */
		private function addRandomOrgan(c:uint, r:uint, duration:uint, yOffset:uint):Organ
		{
			var organClass:Class = randomOrganTypes[uint(Math.random() * randomOrganTypes.length)];

			var o:Organ = new organClass;

			o.x = c * 90 - 350;
			o.y = r * 90 - 350 - yOffset;

			o.col = c;
			o.row = r;

			addChild(o);

			o.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);

			o.setTargetY(r * 90 - 350, duration);

			return o;
		}

		/**
		 * init
		 *
		 * @param	e
		 */
		protected override function init(e:Event):void
		{
			super.init(e);

			delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, delayTimerComplete);

			for (var r:uint = 0; r < 8; ++r)
				for (var c:uint = 0; c < 8; ++c)
				{
					const duration:uint = (1 + 0.1 * c - 0.1 * r) * 30;

					var o:Organ = addRandomOrgan(c, r, duration, 800);

					organs.push(o);
				}

			delayTimer.start();

			addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);

			textSpleen.visible = false;
			textStomach.visible = false;
			textTurnsLeft.visible = false;
		}

		/**
		 * setOrganTargetPosition
		 *
		 * @param	o
		 */
		private function setOrganTargetPosition(o:Organ, c:uint, r:uint, finishedCallback:Function = null):void
		{
			const targetX:Number = c * 90 - 350;
			const targetY:Number = r * 90 - 350;

			o.targetCol = c;
			o.targetRow = r;

			o.setTargetXAndY(targetX, targetY, 15, finishedCallback);
		}

		/**
		 * handleTargetFinished
		 *
		 * @param	o
		 */
		private function handleTargetFinished(o:Organ):void
		{
			trace("handleTargetFinished", o);

			const ia:uint = swapOrganA.col + swapOrganA.row * 8;
			const ib:uint = swapOrganB.col + swapOrganB.row * 8;

			organs[ia] = swapOrganB;
			organs[ib] = swapOrganA;

			const isStomach:Boolean = swapOrganA is OrganStomach || swapOrganB is OrganStomach;
			const isSpleen:Boolean = swapOrganA is OrganSpleen || swapOrganB is OrganSpleen;

			if (!isStomach && findMatches(false))
			{
				swapOrganA.setPosFromTarget();
				swapOrganB.setPosFromTarget();

				delayTimerComplete(null);
			}
			else
			{
				// if either is a spleen, it can only move if the result is a match
				// if either is a stomach, it cannot be moved by player (no checking for matches too)
				if (isStomach || isSpleen)
				{
					soundError.play();

					// no match, go back
					organs[ia] = swapOrganA;
					organs[ib] = swapOrganB;

					setOrganTargetPosition(swapOrganA, swapOrganA.col, swapOrganA.row);
					setOrganTargetPosition(swapOrganB, swapOrganB.col, swapOrganB.row, handleNoMatchFinished);
				}
				else
				{
					soundNoMatch.play();

					swapOrganA.setPosFromTarget();
					swapOrganB.setPosFromTarget();

					delayTimerComplete(null);
				}
			}
		}

		/**
		 * handleNoMatchFinished
		 *
		 * @param	o
		 */
		private function handleNoMatchFinished(o:Organ):void
		{
			clearSwap();
			allowPlayerMove = true;
		}

		/**
		 * clearSwap
		 */
		private function clearSwap():void
		{
			swapOrganA = null;
			swapOrganB = null;
		}

		/**
		 * handleMouseUp
		 *
		 * @param	e
		 */
		private function handleMouseUp(e:MouseEvent):void
		{
			if (!allowPlayerMove)
				return;

			//if (swapOrgan != null)
				clearSwap();
		}

		/**
		 * handleMouseDown
		 *
		 * @param	e
		 */
		private function handleMouseDown(e:MouseEvent):void
		{
			if (!allowPlayerMove)
				return;

			var organ:Organ = e.target as Organ;

			//if (swapOrgan != null)
				clearSwap();

			// stomach cannot be moved by player
			if (organ) // && !(organ is OrganStomach))
			{
				swapOrganA = organ;
				addChild(swapOrganA);

				lastMouseX = mouseX;
				lastMouseY = mouseY;
			}
		}

		/**
		 * swapOrgans
		 *
		 * @param	o1
		 * @param	o2
		 */
		private function swapOrgans(o1:Organ, dc:int, dr:int):void
		{
			const c1:int = o1.col + dc;
			const r1:int = o1.row + dr;

			swapOrganB = organs[c1 + r1 * 8]

			allowPlayerMove = false;

			setOrganTargetPosition(o1, c1, r1);

			const c2:int = swapOrganB.col - dc;
			const r2:int = swapOrganB.row - dr;

			setOrganTargetPosition(swapOrganB, c2, r2, handleTargetFinished);
		}

		/**
		 * handleMouseMove
		 *
		 * @param	e
		 */
		private function handleMouseMove(e:MouseEvent):void
		{
			if (!allowPlayerMove)
				return;

			if (swapOrganA)
			{
				// check if player is swapping the organ
				const dx:Number = mouseX - lastMouseX;
				const dy:Number = mouseY - lastMouseY;

				const adx:Number = Math.abs(dx);
				const ady:Number = Math.abs(dy);

				if (ady >= 8 || adx >= 8)
				{
					if (adx > ady)
					{
						if (dx < 0 && swapOrganA.col > 0)
						{
							swapOrgans(swapOrganA, -1, 0);
						}
						else if (dx > 0 && swapOrganA.col < 7)
						{
							swapOrgans(swapOrganA, 1, 0);
						}
					}
					else
					{
						if (dy < 0 && swapOrganA.row > 0)
						{
							swapOrgans(swapOrganA, 0, -1);
						}
						else if (dy > 0 && swapOrganA.row < 7)
						{
							swapOrgans(swapOrganA, 0, 1);
						}
					}
				}
			}
		}

		/**
		 * delayTimerComplete
		 * @param	e
		 */
		private function delayTimerComplete(e:TimerEvent):void
		{
			//trace(this, "delayTimerComplete - done");

			if (findMatches(true))
			{
				soundCrush.play();

				if (hasSpleen)
					++turnsLeft;

				// keep finding all matches
				delayTimer.start();
			}
			else
			{
				clearSwap();
				allowPlayerMove = true;

				textTurns.text = "Turns: " + moveCount;
				++moveCount;

				if (moveCount > 3 && !hasStomach && Math.random() < 0.5)
				{
					spawnStomach();
				}
				else if (moveCount > 6 && hasStomach && !hasSpleen && Math.random() < 0.5)
				{
					spawnSpleen();
				}

				if (hasSpleen)
					checkGameOver();
			}
		}

		/**
		 * checkGameOver
		 */
		private function checkGameOver():void
		{
			const sameRow:Boolean = theSpleen.row == theStomach.row;
			const sameCol:Boolean = theSpleen.col == theStomach.col;

			const adjRow:Boolean = theSpleen.row + 1 == theStomach.row || theSpleen.row - 1 == theStomach.row;
			const adjCol:Boolean = theSpleen.col + 1 == theStomach.col || theSpleen.col - 1 == theStomach.col;

			if ( (sameRow && adjCol) || (sameCol && adjRow) )
			{
				// you win
				ocs.youWin = true;
				ocs.play();
			}
			else
			{
				--turnsLeft;

				if (turnsLeft <= 0)
				{
					// you lose
					ocs.youWin = false;
					ocs.play();
				}

				updateTurnsLeft();
			}
		}

		/**
		 * updateTurnsLeft
		 */
		private function updateTurnsLeft():void
		{
			textTurnsLeft.text = "Turns Left: " + turnsLeft;
		}

		/**
		 * spawnSpleen
		 */
		private function spawnSpleen():void
		{
			hasSpleen = true;
			textSpleen.visible = true;
			organSpleen.visible = true;

			var i:uint = Math.random() * organs.length;

			var retry:int = 16;

			/// @todo can spawn right on stomach
			while (retry-- > 0 && (!(organs[i] is OrganStomach) || organs[i].row == theStomach.row || organs[i].col == theStomach.col))
				i = Math.random() * organs.length;

			/// @todo you lose if no spleen or you win what are the odds!

			theSpleen = new OrganSpleen();
			changeOrgan(i, theSpleen);

			const rowDist:uint = Math.abs(theStomach.row - theSpleen.row) + 2;
			const colDist:uint = Math.abs(theStomach.col - theSpleen.col) + 1;

			turnsLeft = (rowDist + colDist * 0.5) * (0.8 + 0.4 * Math.random());

			if (turnsLeft < 2)
				turnsLeft = 2;

			if (turnsLeft > 8)
				turnsLeft = 8;

			textTurnsLeft.visible = true;

			soundSpleen.play();
		}

		/**
		 * spawnStomach
		 */
		private function spawnStomach():void
		{
			hasStomach = true;
			textStomach.visible = true;
			organStomach.visible = true;

			const i:uint = Math.random() * organs.length;
			//const i:uint = 7;

			theStomach = new OrganStomach();
			changeOrgan(i, theStomach);

			soundStomach.play();
		}

		/**
		 * changeOrgan
		 *
		 * @param	i
		 * @param	newOrgan
		 */
		private function changeOrgan(i:uint, newOrgan:Organ):void
		{
			var o:Organ = organs[i];

			removeChild(o);

			organs[i] = newOrgan;

			newOrgan.x = o.x;
			newOrgan.y = o.y;
			newOrgan.row = o.row;
			newOrgan.col = o.col;

			addChild(newOrgan);

			newOrgan.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}

		/**
		 * setMatch
		 *
		 * @param	o
		 */
		private function setMatched(o:Organ):void
		{
			o.matched = true;
		}

		/**
		 * findMatches
		 */
		protected function findMatches(replace:Boolean):Boolean
		{
			var j:int = 0;
			var k:int = 0;
			var matches:Array = new Array();

			//for (j = 8 * 2 - 1; j >= 0; --j)
			for (j = 0; j < 8 * 2; ++j)
			{
				var matchCount:uint = 0;
				var colCount:uint = 1;
				var prevOrgan:Organ = null;
				matches.length = 0;

				//for (k = 7; k >= 0; --k)
				for (k = 0; k < 8; ++k)
				{
					var i:uint = j < 8 ? k + j * 8 : (j - 8) + k * 8;

					var currOrgan:Organ = organs[i];

					//trace("findMatches", i, matchCount, currOrgan, currOrgan.col, currOrgan.row, currOrgan.x, currOrgan.y);

					if (getQualifiedClassName(currOrgan) == getQualifiedClassName(prevOrgan))
					{
						if (matchCount == 0)
						{
							matchCount = 2;
							matches.push(prevOrgan);
							matches.push(currOrgan);
						}
						else
						{
							++matchCount;
							matches.push(currOrgan);
						}
						if (currOrgan.col == prevOrgan.col)
							++colCount;
					}
					else
					{
						if (matchCount >= 3)
							break;
						else
						{
							matchCount = 0;
							matches.length = 0;
							colCount = 1;
						}
					}

					prevOrgan = currOrgan;
				}

				if (matchCount >= 3)
				{

					if (matchCount != matches.length)
						trace("Error!", matchCount, matches.length);

					var a:Array = [0, 0, 0, 0, 0, 0, 0, 0];

					trace("findMatches", matchCount, matches.join());

					if (!replace)
						return true;

					//matches.forEach(setMatched);
					//for each (var o:Organ in matches)
					for (var l:uint = 0; l < matches.length; ++l)
					{
						var o:Organ = matches[l];
						//trace(o, matches.length);
						// delete it, shift the column in the vector, and make another one
						replaceOrgan(o, ++a[o.col], colCount);
					}

					return true;
				}
			}

			trace("findMatches - NO MATCHES");

			return false;
		}

		/**
		 * replaceOrgan
		 *
		 * @param	o
		 */
		private function replaceOrgan(o:Organ, yOffset:uint, colCount:uint):void
		{
			var r:uint = o.row;
			var c:uint = o.col;

			for (var i:uint = r; i >= 1; --i)
			{
				var j1:uint = c + i * 8;
				var j2:uint = c + (i - 1) * 8;

				//var o1:Organ = organs[j1];
				var o2:Organ = organs[j2];

				//trace(o2, "->", o1);

				const targetY:Number = i * 90 - 350; // o1.row

				//trace("replaceOrgan", targetY, o2.col, o2.row, o1.col, o1.row, j1, j2);

				o2.row = i;
				//o2.col = o1.col;

				o2.setTargetY(targetY, 5 + 10 * colCount);

				organs[j1] = organs[j2];
			}

			/// @todo: splat
			organs[c] = addRandomOrgan(c, 0, 5 + 10 * colCount, 90 * yOffset);

			removeChild(o);
		}
	}
}
