package bestiary.world.elements
{
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import bestiary.data.*;
	import bestiary.ui.*;
	import bestiary.ui.buttons.*;
	import bestiary.world.data.*;
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
		public function set figureScale(pVal:Number) { _figure.scaleX = _figure.scaleY = pVal; }
		
		// Constructor
		// pData = { data:MonsterData }
		public function MonsterTray(pData:Object) {
			super();
			_data = pData.data;
			
			_monsterTray = addChild(new Sprite());
			_monsterTray.y = 140;
			
			_poseTray = addChild(new RoundedRectangle({ x:0, y:185, width:600, height:40, origin:0.5 }));
			_poseTray.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			
			var tIDTextField = addChild(new TextField());
			tIDTextField.defaultTextFormat = new TextFormat("Verdana", 18, 0xC2C2DA);
			tIDTextField.autoSize = TextFieldAutoSize.CENTER;
			tIDTextField.text = "ID: "+_data.id;
			tIDTextField.x = (900*0.5) - (tIDTextField.textWidth*1) - 11;
			tIDTextField.y = -(425*0.5) + (tIDTextField.textHeight*0.5) - 3;
			
			_buttons = [];
			var tButton:PushButton;
			var tWidth = 75, tXMargin = 10, tXSpacing = tWidth + tXMargin, tX = tXMargin-(_data.poses.length*0.5*tXSpacing)-tXSpacing;
			for(var i:int = 0; i < _data.poses.length; i++) {
				tButton = _poseTray.addChild(new PushButton({ x:tX += tXSpacing, y:-15, width:tWidth, height:30, data:{ index:i }, text:_data.poses[i].id, allowToggleOff:false }));
				tButton.addEventListener(PushButton.STATE_CHANGED_BEFORE, _onPoseButtonClicked);
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
			figureScale = tScale;
			toggleAnimation(Main.costumes.animatePose);
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
