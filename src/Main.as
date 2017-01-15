package
{
	import com.adobe.images.*;
	import com.piterwilson.utils.*;
	import com.fewfre.utils.AssetManager;
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;
	
	import bestiary.ui.*;
	import bestiary.ui.panes.*;
	import bestiary.ui.buttons.*;
	import bestiary.data.*;
	import bestiary.world.data.*;
	import bestiary.world.elements.*;
	
	import fl.controls.*;
	import fl.events.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*
	import flash.external.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
	
	public class Main extends MovieClip
	{
		// Storage
		public static var costumes	: Costumes;
		
		internal var character		: Character;
		internal var loaderDisplay	: LoaderDisplay;
		
		internal var _toolbox		: Toolbox;
		
		internal var monsterTrayCont:Sprite;
		internal var curMonsterTray:MonsterTray;
		internal var curMonsterTrayIndex:int;
		
		internal var tabPanes:Array; // Must contain all TabPanes to be able to close them properly.
		internal var tabPanesMap:Object; // Tab pane should be stored in here to easy access the one you desire.
		
		// Constructor
		public function Main() {
			super();
			Fewf.init();
			
			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 10;
			
			BrowserMouseWheelPrevention.init(stage);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
			
			// Start preload
			Fewf.assets.load([
				"resources/config.json",
			]);
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, _onPreloadComplete);

			loaderDisplay = addChild( new LoaderDisplay({ x:stage.stageWidth * 0.5, y:stage.stageHeight * 0.5 }) );
		}
		
		internal function _onPreloadComplete(event:Event) : void {
			Fewf.assets.removeEventListener(AssetManager.LOADING_FINISHED, _onPreloadComplete);
			ConstantsApp.lang = Fewf.assets.getData("config").language;
			
			// Start main load
			var tPacks = [
				"resources/i18n/"+ConstantsApp.lang+".json"
			];
			for(var i:int = 0; i <= ConstantsApp.MONSTERS_COUNT; i++) { tPacks.push("resources/x_monstre_"+i+".swf"); }
			Fewf.assets.load(tPacks);
			Fewf.assets.load(tPacks);
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, _onLoadComplete);
		}

		internal function _onLoadComplete(event:Event) : void {
			Fewf.assets.removeEventListener(AssetManager.LOADING_FINISHED, _onLoadComplete);
			loaderDisplay.destroy();
			removeChild( loaderDisplay );
			loaderDisplay = null;
			
			Fewf.i18n.parseFile(Fewf.assets.getData(ConstantsApp.lang));
			
			_init();
		}
		
		private function _init() : void {
			costumes = new Costumes();
			costumes.init();
			
			/****************************
			* Setup UI
			*****************************/
			// Toolbox - addChild() called at end of function so it ends up on top
			_toolbox = new Toolbox({
				x:stage.stageWidth*0.5, y:28, character:character,
				onSave:_onSaveClicked, onAnimate:_onPlayerAnimationToggle, onRandomize:_onRandomizeDesignClicked,
				onScale:_onScaleSliderChange
			});
			
			/****************************
			* Create tabs and panes
			*****************************/
			this.tabPanes = new Array();
			this.tabPanesMap = new Object();
			
			monsterTrayCont = addChild(new Sprite());
			monsterTrayCont.x = stage.stageWidth * 0.5;
			monsterTrayCont.y = stage.stageHeight * 0.5;
			
			// Create the panes
			var tPane:MonsterTray;
			for(var i:int = 0; i < costumes.monsters.length; i++) {
				tPane = new MonsterTray({ data:costumes.monsters[i] });
				tabPanes.push(tPane);
			}
			_selectMonsterTray(0);
			
			/****************************
			* Click Panes
			*****************************/
			var tWidth:Number = 500, tHeight:Number=stage.stageHeight, tClickAreaWidth:Number = 100, tX:Number, tY:Number = tHeight*0.5;
			
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
			
			tX = stage.stageWidth - tClickAreaWidth;
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
		}
		
		private function handleMouseWheel(pEvent:MouseEvent) : void {
			//if(this.mouseX < this.shopTabs.x) {
				_toolbox.scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				curMonsterTray.figureScale = _toolbox.scaleSlider.getValueAsScale();
			//}
		}
		
		private function _onScaleSliderChange(pEvent:Event):void {
			curMonsterTray.figureScale = _toolbox.scaleSlider.getValueAsScale();
		}
		
		private function _onPlayerAnimationToggle(pEvent:Event):void {
			costumes.animatePose = !costumes.animatePose;
			if(costumes.animatePose) {
				curMonsterTray.figure.play();
			} else {
				curMonsterTray.figure.stop();
			}
			_toolbox.toggleAnimateButtonAsset(costumes.animatePose);
		}
		
		private function _onSaveClicked(pEvent:Event) : void {
			Main.costumes.saveMovieClipAsBitmap(curMonsterTray.figure, "monster"+curMonsterTray.data.id, curMonsterTray.figureScale);
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
		
		//{REGION tMonsterTray Management
			private function _selectMonsterTray(pNum:int) : void {
				if(curMonsterTray) { monsterTrayCont.removeChild(curMonsterTray); }
				curMonsterTrayIndex = pNum < 0 ? tabPanes.length+pNum : ( pNum >= tabPanes.length ? tabPanes.length-pNum : pNum );
				curMonsterTray = monsterTrayCont.addChild(tabPanes[curMonsterTrayIndex]);
				curMonsterTray.open(_toolbox.scaleSlider.value*0.1);
			}
		//}END tMonsterTray Management
	}
}
