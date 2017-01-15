package bestiary.ui 
{
	import bestiary.data.*;
	import bestiary.ui.*;
	import bestiary.ui.buttons.*;
	import flash.display.*;
	import flash.display.Shape;
	import flash.events.*;
	
	public class ShopTabContainer extends RoundedRectangle
	{
		// Constants
		public static const EVENT_SHOP_TAB_CLICKED			: String = "shop_tab_clicked";
		
		// Storage
		public var tabs:Array;
		
		// Constructor
		// pData = { x:Number, y:Number, width:Number, height:Number }
		public function ShopTabContainer(pData:Object)
		{
			super(pData);
			
			this.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			
			var tTabInfo = [
				/*{ text:"Config", type:"config" },
				{ text:"Skin", type:ITEM.SKIN },
				{ text:"Hair", type:ITEM.HAIR },
				{ text:"Head", type:ITEM.HEAD },
				{ text:"Shirts", type:ITEM.SHIRT },
				{ text:"Pants", type:ITEM.PANTS },
				{ text:"Shoes", type:ITEM.SHOES },
				{ text:"Objects", type:ITEM.OBJECT },
				{ text:"Pose", type:ITEM.POSE }*/
			];
			
			var tXMargin:Number = 5;
			var tYMargin:Number = 5;
			var tHeight:Number = Math.min(65, (this.Height - tYMargin) / tTabInfo.length - tYMargin);
			var tWidth:Number = this.Width - (tXMargin * 2);
			var tYSpacing:Number = tHeight + tYMargin;
			var tX:Number = tXMargin;
			var tY:Number = tYMargin - tYSpacing; // Go back one space for when for loop adds one space.
			
			tabs = new Array();
			for(var i:int = 0; i < tTabInfo.length; i++) {
				_createTab(tTabInfo[i].text, tX, tY += tYSpacing, tWidth, tHeight, tTabInfo[i].type);
			}
		}
		
		private function _createTab(pText:String, pX:Number, pY:Number, pWidth:Number, pHeight:Number, pEvent:String) : PushButton {
			var tBttn:PushButton = new PushButton({ x:pX, y:pY, width:pWidth, height:pHeight, text:pText, allowToggleOff:false });
			tabs.push(addChild(tBttn));
			tBttn.addEventListener(PushButton.STATE_CHANGED_BEFORE, function(tBttn){ return function(){ untoggle(tBttn, pEvent); }; }(tBttn));//, false, 0, true
			return tBttn;
		}

		public function UnpressAll() : void {
			untoggle();
		}
		
		private function untoggle(pTab:PushButton=null, pEvent:String=null) : void {
			if (pTab != null && pTab.pushed) { return; }
			
			for(var i:int = 0; i < tabs.length; i++) {
				if (tabs[i].pushed && tabs[i] != pTab) {
					tabs[i].toggleOff();
				}
			}
			
			if(pEvent!=null) { dispatchEvent(new DataEvent(EVENT_SHOP_TAB_CLICKED, false, false, pEvent)); }
		}
	}
}