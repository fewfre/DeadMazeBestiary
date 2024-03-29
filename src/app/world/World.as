package app.world
{
	import com.adobe.images.*;
	import com.piterwilson.utils.*;
	import com.fewfre.utils.AssetManager;
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;
	
	import app.ui.*;
	import app.ui.panes.*;
	import app.ui.lang.*;
	import app.ui.buttons.*;
	import app.data.*;
	import app.world.data.*;
	import app.world.elements.*;
	
	import fl.controls.*;
	import fl.events.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*
	import flash.external.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
	
	public class World extends MovieClip
	{
		// Storage
		internal var character		: Character;
		
		internal var _toolbox		: Toolbox;
		internal var _langScreen	: LangScreen;
		
		internal var monsterTrayCont:Sprite;
		internal var curMonsterTray:MonsterTray;
		internal var curMonsterTrayIndex:int;
		
		internal var tabPanes:Array; // Must contain all TabPanes to be able to close them properly.
		internal var tabPanesMap:Object; // Tab pane should be stored in here to easy access the one you desire.
		
		// Constructor
		public function World(pStage:Stage) {
			super();
			_buildWorld(pStage);
			pStage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
		}
		
		private function _buildWorld(pStage:Stage) {
			GameAssets.init();
			
			/****************************
			* Setup UI
			*****************************/
			// Toolbox - addChild() called at end of function so it ends up on top
			_toolbox = new Toolbox({
				x:pStage.stageWidth*0.5, y:28, character:character,
				onSave:_onSaveClicked, onAnimate:_onPlayerAnimationToggle, onRandomize:_onRandomizeDesignClicked,
				onScale:_onScaleSliderChange
			});
			
			// addChild() called at end of function so it ends up on top
			var tLangButton = new LangButton({ x:22, y:17, width:30, height:25, origin:0.5 }); // y:pStage.stageHeight-17
			tLangButton.addEventListener(ButtonBase.CLICK, _onLangButtonClicked);
			
			// addChild() called at end of function so it ends up on top
			var tAppInfoBox = new AppInfoBox({ x:tLangButton.x+(tLangButton.Width*0.5)+(25*0.5)+2, y:17 });
			
			/****************************
			* Screens
			*****************************/
			_langScreen = new LangScreen({  });
			_langScreen.addEventListener(LangScreen.CLOSE, _onLangScreenClosed);
			
			/****************************
			* Create tabs and panes
			*****************************/
			this.tabPanes = new Array();
			this.tabPanesMap = new Object();
			
			monsterTrayCont = addChild(new Sprite());
			monsterTrayCont.x = pStage.stageWidth * 0.5;
			monsterTrayCont.y = pStage.stageHeight * 0.5;
			
			// Create the panes
			var tPane:MonsterTray;
			for(var i:int = 0; i < GameAssets.monsters.length; i++) {
				tPane = new MonsterTray({ data:GameAssets.monsters[i] });
				tabPanes.push(tPane);
			}
			_selectMonsterTray(0);
			
			/****************************
			* Click Panes
			*****************************/
			var tWidth:Number = 500, tHeight:Number=pStage.stageHeight, tClickAreaWidth:Number = 100, tX:Number, tY:Number = tHeight*0.5;
			
			tX = tClickAreaWidth;
			var tLeftClickPane:Sprite = addChild(new Sprite());
			tLeftClickPane.x = tX;
			tLeftClickPane.y = tY;
			tLeftClickPane.graphics.beginFill(0x000000, 0.1);
			tLeftClickPane.graphics.drawRect(-tWidth, -tHeight*0.5, tWidth, tHeight);
			tLeftClickPane.graphics.endFill();
			tLeftClickPane.addEventListener(MouseEvent.CLICK, function(e:Event){ _selectMonsterTray(curMonsterTrayIndex-1); });
			
			tLeftClickPane.graphics.lineStyle(15, 0xFFFFFF, 1, true);
			tLeftClickPane.graphics.moveTo(-70, 0);
			tLeftClickPane.graphics.lineTo(-30, -40);
			tLeftClickPane.graphics.moveTo(-70, 0);
			tLeftClickPane.graphics.lineTo(-30, 40);
			
			tX = pStage.stageWidth - tClickAreaWidth;
			var tRightClickPane:Sprite = addChild(new Sprite());
			tRightClickPane.x = tX;
			tRightClickPane.y = tY;
			tRightClickPane.graphics.beginFill(0x000000, 0.1);
			tRightClickPane.graphics.drawRect(0, -tHeight*0.5, tWidth, tHeight);
			tRightClickPane.graphics.endFill();
			tRightClickPane.addEventListener(MouseEvent.CLICK, function(e:Event){ _selectMonsterTray(curMonsterTrayIndex+1); });
			
			tRightClickPane.graphics.lineStyle(15, 0xFFFFFF, 1, true);
			tRightClickPane.graphics.moveTo(70, 0);
			tRightClickPane.graphics.lineTo(30, -40);
			tRightClickPane.graphics.moveTo(70, 0);
			tRightClickPane.graphics.lineTo(30, 40);
			
			addChild(_toolbox); // We want it to be on top, but need to declare slider earlier on.
			addChild(tLangButton); // We want it to be on top
			addChild(tAppInfoBox); // We want it to be on top
		}
		
		private function _onMouseWheel(pEvent:MouseEvent) : void {
			//if(this.mouseX < this.shopTabs.x) {
				_toolbox.scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				curMonsterTray.figureScale = _toolbox.scaleSlider.value;
			//}
		}
		
		private function _onScaleSliderChange(pEvent:Event):void {
			curMonsterTray.figureScale = _toolbox.scaleSlider.value;
		}
		
		private function _onPlayerAnimationToggle(pEvent:Event):void {
			GameAssets.animatePose = !GameAssets.animatePose;
			if(GameAssets.animatePose) {
				curMonsterTray.figure.play();
			} else {
				curMonsterTray.figure.stop();
			}
			_toolbox.toggleAnimateButtonAsset(GameAssets.animatePose);
		}
		
		private function _onSaveClicked(pEvent:Event) : void {
			GameAssets.saveMovieClipAsBitmap(curMonsterTray.figure, "monster"+curMonsterTray.data.id, curMonsterTray.figureScale);
		}
		
		private function _onRandomizeDesignClicked(pEvent:Event) : void {
			for(var i:int = 0; i < ITEM.LAYERING.length; i++) {
				_randomItemOfType(ITEM.LAYERING[i]);
			}
			_randomItemOfType(ITEM.POSE);
		}
		
		private function _randomItemOfType(pType:String) : void {
			var tButtons = getButtonArrayByType(pType);
			var tLength = tButtons.length; if(pType == ITEM.SKIN) { /* Don't select "transparent" */ tLength--; }
			tButtons[ Math.floor(Math.random() * tLength) ].toggleOn();
		}
		
		private function _onLangButtonClicked(pEvent:Event) : void {
			_langScreen.open();
			addChild(_langScreen);
		}

		private function _onLangScreenClosed(pEvent:Event) : void {
			removeChild(_langScreen);
		}

		
		//{REGION tMonsterTray Management
			private function _selectMonsterTray(pNum:int) : void {
				if(curMonsterTray) { monsterTrayCont.removeChild(curMonsterTray); }
				curMonsterTrayIndex = pNum < 0 ? tabPanes.length+pNum : ( pNum >= tabPanes.length ? tabPanes.length-pNum : pNum );
				curMonsterTray = monsterTrayCont.addChild(tabPanes[curMonsterTrayIndex]);
				curMonsterTray.open(_toolbox.scaleSlider.value);
			}
		//}END tMonsterTray Management
	}
}
