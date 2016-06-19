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
		public static var assets	: AssetManager;
		public static var costumes	: Costumes;
		
		internal var character		: Character;
		internal var loaderDisplay	: LoaderDisplay;
		
		internal var animateButton	: SpriteButton;
		internal var linkTray		: LinkTray;
		internal var scaleSlider	: FancySlider;
		
		internal var monsterTrayCont:Sprite;
		internal var curMonsterTray:MonsterTray;
		internal var curMonsterTrayIndex:int;
		
		internal var tabPanes:Array; // Must contain all TabPanes to be able to close them properly.
		internal var tabPanesMap:Object; // Tab pane should be stored in here to easy access the one you desire.
		
		// Constructor
		public function Main()
		{
			super();
			
			assets = new AssetManager();
			var tPacks = [];
			for(var i:int = 0; i <= ConstantsApp.MONSTERS_COUNT; i++) { tPacks.push("resources/x_monstre_"+i+".swf"); }
			assets.load(tPacks);
			assets.addEventListener(AssetManager.LOADING_FINISHED, _onLoadComplete);
			
			loaderDisplay = addChild( new LoaderDisplay({ x:stage.stageWidth * 0.5, y:stage.stageHeight * 0.5, assetManager:assets }) );
			
			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 10;
			
			addEventListener(Event.ENTER_FRAME, update);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
		}
		
		internal function _onLoadComplete(event:Event) : void
		{
			loaderDisplay.destroy();
			removeChild( loaderDisplay );
			loaderDisplay = null;
				
			costumes = new Costumes( assets );
			costumes.init();
			
			/****************************
			* Create Character
			*****************************/
			/*var parms:flash.net.URLVariables = null;
			try {
				var urlPath:String = ExternalInterface.call("eval", "window.location.href");
				if(urlPath && urlPath.indexOf("?") > 0) {
					urlPath = urlPath.substr(urlPath.indexOf("?") + 1, urlPath.length);
					parms = new flash.net.URLVariables();
					parms.decode(urlPath);
				}
			} catch (error:Error) { };
			
			this.character = addChild(new Character({ x:180, y:375,
				skin:costumes.skins[costumes.defaultSkinIndex],
				pose:costumes.poses[costumes.defaultPoseIndex],
				params:parms
			}));*/
			
			/****************************
			* Setup UI
			*****************************/
			// Toolbox
			var tools:RoundedRectangle = new RoundedRectangle({ x:(stage.stageWidth - 365) * 0.5, y:10, width:365, height:35 });
			tools.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			
			var btn:ButtonBase, tButtonSize = 28, tButtonSizeSpace=5;
			btn = tools.addChild(new SpriteButton({ x:tButtonSizeSpace, y:4, width:tButtonSize, height:tButtonSize, obj_scale:0.4, obj:new $LargeDownload() }));
			btn.addEventListener(ButtonBase.CLICK, _onSaveClicked);
			
			animateButton = tools.addChild(new SpriteButton({ x:tButtonSizeSpace+(tButtonSize+tButtonSizeSpace), y:4, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new $PauseButton() }));
			animateButton.addEventListener(ButtonBase.CLICK, _onPlayerAnimationToggle);
			
			/*btn = tools.addChild(new SpriteButton({ x:tButtonSizeSpace+(tButtonSize+tButtonSizeSpace)*2, y:4, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new $Refresh() }));
			btn.addEventListener(ButtonBase.CLICK, _onRandomizeDesignClicked);*/
			
			btn = tools.addChild(new SpriteButton({ x:tools.width-tButtonSizeSpace-tButtonSize, y:4, width:tButtonSize, height:tButtonSize, obj_scale:0.35, obj:new $GitHubIcon() }));
			btn.addEventListener(ButtonBase.CLICK, function():void { navigateToURL(new URLRequest(ConstantsApp.SOURCE_URL), "_blank");  });
			
			var tSliderWidth = 315 - (tButtonSize+tButtonSizeSpace)*3.5;
			this.scaleSlider = tools.addChild(new FancySlider({ value: 20, min:10, max:30, x:tools.width*0.5-tSliderWidth*0.5+(tButtonSize+tButtonSizeSpace)*0.5, y:tools.Height*0.5, width:tSliderWidth }));
			this.scaleSlider.addEventListener(FancySlider.CHANGE, _onScaleSliderChange);
			
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
			
			addChild(tools); // We want it to be on top, but need to declare slider earlier on.
		}
		
		public function update(pEvent:Event):void
		{
			if(loaderDisplay != null) { loaderDisplay.update(0.1); }
		}
		
		private function handleMouseWheel(pEvent:MouseEvent) : void {
			//if(this.mouseX < this.shopTabs.x) {
				scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				curMonsterTray.figureScale = scaleSlider.getValueAsScale();
			//}
		}
		
		private function _onScaleSliderChange(pEvent:Event):void {
			curMonsterTray.figureScale = scaleSlider.getValueAsScale();
		}
		
		private function _onPlayerAnimationToggle(pEvent:Event):void {
			costumes.animatePose = !costumes.animatePose;
			if(costumes.animatePose) {
				curMonsterTray.figure.play();
				animateButton.ChangeImage(new $PauseButton());
			} else {
				curMonsterTray.figure.stop();
				animateButton.ChangeImage(new $PlayButton());
			}
		}
		
		private function _onSaveClicked(pEvent:Event) : void {
			Main.costumes.saveMovieClipAsBitmap(curMonsterTray.figure, "monster"+curMonsterTray.data.id, curMonsterTray.figure.scaleX);
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
				curMonsterTray.open(scaleSlider.value*0.1);
			}
		//}END tMonsterTray Management
	}
}
