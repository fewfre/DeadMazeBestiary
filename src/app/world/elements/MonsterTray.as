package app.world.elements
{
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.world.data.*;
	import fl.containers.*;
	import flash.display.*;
	import flash.text.*;
	
	public class MonsterTray extends MovieClip
	{
		// Storage
		private var _data	: MonsterData;
		private var _figure	: MovieClip;
		
		private var _monsterTray : Sprite;
		private var _poseTray : RoundedRectangle;
		
		private var _buttons : Array;
		
		// Properties
		public function get figure() : MovieClip { return _figure; }
		public function get data() : MonsterData { return _data; }
		public function get figureScale():Number { return _figure.scaleX; }
		public function set figureScale(pVal:Number) : void { _figure.scaleX = _figure.scaleY = pVal; }
		
		// Constructor
		// pData = { data:MonsterData }
		public function MonsterTray(pData:Object) {
			super();
			_data = pData.data;
			
			_monsterTray = addChild(new Sprite());
			_monsterTray.y = 140;
			
			_poseTray = addChild(new RoundedRectangle({ x:0, y:185, width:666, height:40, origin:0.5 }));
			_poseTray.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			
			var tIDTextField = addChild(new TextBase({ text:"monster_id", size:18, values:_data.id, x:(900*0.5)-11, y:-(425*0.5)+3, originX:1, originY:0 }));
			
			_buttons = [];
			var tButton:PushButton;
			var tWidth = 75, tXMargin = 10, tScale = 1;
			if(_data.poses.length > 7) {
				tScale = (_poseTray.Width-10) / (tWidth*_data.poses.length + tXMargin*(_data.poses.length-1));
				tWidth *= tScale;
				tXMargin *= tScale;
			}
			var tXSpacing = tWidth + tXMargin, tX = -2+tXMargin-(_data.poses.length*0.5*tXSpacing)-tXSpacing;
			for(var i:int = 0; i < _data.poses.length; i++) {
				tButton = _poseTray.addChild(new PushButton({ x:tX += tXSpacing, y:-15, width:tWidth, height:30, data:{ index:i }, text:_data.poses[i].id, allowToggleOff:false }));
				tButton.addEventListener(PushButton.STATE_CHANGED_BEFORE, _onPoseButtonClicked);
				tButton.Text.size = TextBase.DEFAULT_SIZE*tScale;
				_buttons.push(tButton);
			}
			_buttons[0].toggleOn();
		}
		
		public function open(pScale:Number) : void {
			figureScale = pScale;
			_buttons[0].toggleOn();
		}
		
		public function toggleAnimation(pOn:Boolean=true) : void {
			if(pOn) {
				_figure.play();
			} else {
				_figure.gotoAndPlay(10000);
				_figure.stop();
			}
		}
		
		private function _onPoseButtonClicked(e:FewfEvent) : void {
			var tScale:Number = 1;
			if(_figure) { tScale = figureScale; _monsterTray.removeChild(_figure); }
			_figure = _monsterTray.addChild(new _data.poses[e.data.index].itemClass());
			// Don't let the pose eat mouse input
			_figure.mouseChildren = false;
			_figure.mouseEnabled = false;
			figureScale = tScale;
			toggleAnimation(GameAssets.animatePose);
			untoggle(e.target);
		}
		
		private function untoggle(pButton:PushButton=null) : void {
			if (pButton != null && pButton.pushed) { return; }
			
			for(var i:int = 0; i < _buttons.length; i++) {
				if (_buttons[i].pushed && _buttons[i] != pButton) {
					_buttons[i].toggleOff();
				}
			}
		}
	}
}
