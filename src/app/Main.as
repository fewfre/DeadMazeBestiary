package app
{
	import app.data.*;
	import app.ui.LoaderDisplay;
	import app.world.World;
	
	import com.fewfre.utils.*;

	import flash.display.*;
	import flash.events.*;
	import flash.system.Capabilities;
	
	public class Main extends MovieClip
	{
		// Storage
		private var _loaderDisplay	: LoaderDisplay;
		private var _world			: World;
		private var _config			: Object;
		private var _defaultLang	: String;
		
		// Constructor
		public function Main() {
			super();
			
			if (stage) {
				this._start();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, this._start);
			}
		}
		
		private function _start(...args:*) {
			Fewf.init(stage, this.loaderInfo.parameters.swfUrlBase);
			
			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.frameRate = 10;
			
			BrowserMouseWheelPrevention.init(stage);

			_loaderDisplay = addChild( new LoaderDisplay({ x:stage.stageWidth * 0.5, y:stage.stageHeight * 0.5 }) );
			
			_startPreload();
		}
		
		private function _startPreload() : void {
			_load([
				Fewf.swfUrlBase+"resources/config.json",
			], null, _onPreloadComplete);
		}
		
		internal function _onPreloadComplete() : void {
			_config = Fewf.assets.getData("config");
			_defaultLang = _getDefaultLang(_config.languages["default"]);
			
			_startInitialLoad();
		}
		
		private function _startInitialLoad() : void {
			_load([
				Fewf.swfUrlBase+"resources/i18n/"+_defaultLang+".json",
			], ConstantsApp.VERSION, _onInitialLoadComplete);
			
			/*// Start main load
			var tPacks = [
				"resources/i18n/"+ConstantsApp.lang+".json"
			];
			for(var i:int = 0; i <= ConstantsApp.MONSTERS_COUNT; i++) { tPacks.push("resources/x_monstre_"+i+".swf"); }
			Fewf.assets.load(tPacks);
			Fewf.assets.load(tPacks);
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, _onLoadComplete);*/
		}
		
		private function _onInitialLoadComplete() : void {
			Fewf.i18n.parseFile(_defaultLang, Fewf.assets.getData(_defaultLang));
			
			_startLoad();
		}
		
		// Start main load
		private function _startLoad() : void {
			var tPacks = [
				[Fewf.swfUrlBase+"resources/interface.swf", { useCurrentDomain:true }],
				Fewf.swfUrlBase+"resources/flags.swf",
			];
			var tMonsterPacks = _config.packs.monsters;
			for(var i:int = 0; i < tMonsterPacks.length; i++) { tPacks.push(Fewf.swfUrlBase+"resources/"+tMonsterPacks[i]); }
			_load(tPacks, null, _onLoadComplete);
		}

		internal function _onLoadComplete() : void {
			_loaderDisplay.destroy();
			removeChild( _loaderDisplay );
			_loaderDisplay = null;
			
			_world = addChild(new World(stage));
		}
		
		/***************************
		* Helper Methods
		****************************/
		private function _load(pPacks:Array, pCacheBreaker:String, pCallback:Function) : void {
			Fewf.assets.load(pPacks, pCacheBreaker);
			var tFunc = function(event:Event){
				Fewf.assets.removeEventListener(AssetManager.LOADING_FINISHED, tFunc);
				pCallback();
				tFunc = null; pList = null; pCallback = null;
			};
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, tFunc);
		}
		
		private function _getDefaultLang(pConfigLang:String) : String {
			// If user manually picked a language previously, override system check
			var detectedLang = Fewf.sharedObject.getData("lang") || Capabilities.language;
			
			var tFlagDefaultLangExists:Boolean = false;
			// http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/system/Capabilities.html#language
			if(detectedLang) {
				var tLanguages:Array = _config.languages.list;
				for(var i:Object in tLanguages) {
					if(detectedLang == tLanguages[i].code || detectedLang == tLanguages[i].code.split("-")[0]) {
						return tLanguages[i].code;
					}
					if(pConfigLang == tLanguages[i].code) {
						tFlagDefaultLangExists = true;
					}
				}
			}
			return tFlagDefaultLangExists ? pConfigLang : "en";
		}
	}
}
