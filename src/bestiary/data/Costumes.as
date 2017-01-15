package bestiary.data
{
	import com.adobe.images.*;
	import com.fewfre.utils.*;
	import bestiary.data.*;
	import bestiary.world.data.*;
	import bestiary.world.elements.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.net.*;
	
	public class Costumes
	{
		// Storage
		public var monsters:Array;
		public var animatePose:Boolean;
		
		public function Costumes() {
			super();
			animatePose = true;
		}
		
		public function init() : Costumes {
			var i:int, j:int;
			
			this.monsters = new Array();
			
			var tMonsterData:MonsterData, tClass:Class;
			var tPoseClasses = [ "statique", "course", "attaque", "touche", "mort" ];
			for(i = 0; i <= ConstantsApp.MONSTERS_COUNT; i++) {
				if(Fewf.assets.getLoadedClass( "$Monstre_"+i+"_mort" ) != null) {
					tMonsterData = new MonsterData(i);
					for(j = 0; j < tPoseClasses.length; j++) {
						tClass = Fewf.assets.getLoadedClass( "$Monstre_"+i+"_"+tPoseClasses[j] );
						if(tClass) {
							tMonsterData.poses.push( new ItemData({ id:tPoseClasses[j], itemClass:tClass }) );
						}
					}
					this.monsters.push( tMonsterData );
				}
			}
			
			return this;
		}
		
		// pData = { base:String, type:String, after:String, pad:int, map:Array, sex:Boolean }
		private function _setupCostumeArray(pData:Object) : Array {
			var tArray:Array = new Array();
			var tClassName:String;
			var tClass:Class;
			var tSexSpecificParts:int;
			for(var i = 0; i <= ConstantsApp.MONSTERS_COUNT; i++) {
				if(pData.map) {
					for(var g:int = 0; g < (pData.sex ? 2 : 1); g++) {
						var tClassMap = {  }, tClassSuccess = null;
						tSexSpecificParts = 0;
						for(var j = 0; j <= pData.map.length; j++) {
							tClass = Fewf.assets.getLoadedClass( tClassName = pData.base+(pData.pad ? zeroPad(i, pData.pad) : i)+(pData.after ? pData.after : "")+pData.map[j] );
							if(tClass) { tClassMap[pData.map[j]] = tClass; tClassSuccess = tClass; }
							else if(pData.sex){
								tClass = Fewf.assets.getLoadedClass( tClassName+"_"+(g==0?1:2) );
								if(tClass) { tClassMap[pData.map[j]] = tClass; tClassSuccess = tClass; tSexSpecificParts++ }
							}
						}
						if(tClassSuccess) {
							var tIsSexSpecific = pData.sex && tSexSpecificParts > 0;
							tArray.push( new ItemData({ id:i+(tIsSexSpecific ? (g==1 ? "M" : "F") : ""), type:pData.type, classMap:tClassMap, itemClass:tClassSuccess, gender:(tIsSexSpecific ? (g==1?GENDER.MALE:GENDER.FEMALE) : null) }) );
						}
						if(tSexSpecificParts == 0) {
							break;
						}
					}
				} else {
					tClass = Fewf.assets.getLoadedClass( pData.base+(pData.pad ? zeroPad(i, pData.pad) : i)+(pData.after ? pData.after : "") );
					if(tClass != null) {
						tArray.push( new ItemData({ id:i, type:pData.type, itemClass:tClass}) );
					}
				}
			}
			return tArray;
		}
		
		public function zeroPad(number:int, width:int):String {
			var ret:String = ""+number;
			while( ret.length < width )
				ret="0" + ret;
			return ret;
		}
		
		public function getArrayByType(pType:String) : Array {
			switch(pType) {
				case ITEM.HAIR:		return hair;
				case ITEM.HEAD:		return head;
				case ITEM.SHIRT:	return shirts;
				case ITEM.PANTS:	return pants;
				case ITEM.SHOES:	return shoes;
				case ITEM.OBJECT:	return objects;
				
				case ITEM.SKIN:		return skins;
				case ITEM.POSE:		return poses;
				default: trace("[Costumes](getArrayByType) Unknown type: "+pType);
			}
			return null;
		}
		
		public function getItemFromTypeID(pType:String, pID:String) : ItemData {
			return FewfUtils.getFromArrayWithKeyVal(getArrayByType(pType), "id", pID);
		}

		/****************************
		* Color
		*****************************/
			public function copyColor(copyFromMC:MovieClip, copyToMC:MovieClip) : MovieClip {
				if (copyFromMC == null || copyToMC == null) { return; }
				var tChild1:*=null;
				var tChild2:*=null;
				var i:int = 0;
				while (i < copyFromMC.numChildren)
				{
					tChild1 = copyFromMC.getChildAt(i);
					tChild2 = copyToMC.getChildAt(i);
					if (tChild1.name.indexOf("Couleur") == 0 && tChild1.name.length > 7)
					{
						tChild2.transform.colorTransform = tChild1.transform.colorTransform;
					}
					++i;
				}
				return copyToMC;
			}

			public function colorDefault(pMC:MovieClip) : MovieClip {
				if (pMC == null) { return; }
				
				var tChild:*=null;
				var tHex:int=0;
				var loc1:*=0;
				while (loc1 < pMC.numChildren)
				{
					tChild = pMC.getChildAt(loc1);
					if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7)
					{
						tHex = int("0x" + tChild.name.substr(tChild.name.indexOf("_") + 1, 6));
						applyColorToObject(tChild, tHex);
					}
					++loc1;
				}
				return pMC;
			}
			
			// pData = { obj:DisplayObject, color:String OR int, ?swatch:int, ?name:String }
			public function colorItem(pData:Object) : void {
				if (pData.obj == null) { return; }
				
				var tHex:int = pData.color is Number ? pData.color : int("0x" + pData.color);
				
				var tChild:DisplayObject;
				var i:int=0;
				while (i < pData.obj.numChildren) {
					tChild = pData.obj.getChildAt(i);
					if (tChild.name == pData.name || (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7)) {
						if (!pData.swatch || pData.swatch == tChild.name.charAt(7)) {
							applyColorToObject(tChild, tHex);
						}
					}
					i++;
				}
			}
			
			// pColor is an int hex value. ex: 0x000000
			public function applyColorToObject(pItem:DisplayObject, pColor:int) : void {
				var tR:*=pColor >> 16 & 255;
				var tG:*=pColor >> 8 & 255;
				var tB:*=pColor & 255;
				pItem.transform.colorTransform = new flash.geom.ColorTransform(tR / 128, tG / 128, tB / 128);
			}
			
			public function getNumOfCustomColors(pMC:MovieClip) : int {
				var tChild:*=null;
				var num:int = 0;
				var i:int = 0;
				while (i < pMC.numChildren)
				{
					tChild = pMC.getChildAt(i);
					if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7)
					{
						num++;
					}
					++i;
				}
				return num;
			}
		
		/****************************
		* Asset Creation
		*****************************/
			public function getItemImage(pData:ItemData) : MovieClip {
				var tItem:MovieClip;
				/*switch(pData.type) {
					case ITEM.SHIRT:
					case ITEM.PANTS:
					case ITEM.SHOES:
						tItem = new Pose(poses[defaultPoseIndex].itemClass).apply({ items:[ pData ], removeBlanks:true });
						break;
					default:
						tItem = new pData.itemClass();
						colorDefault(tItem);
						break;
				}*/
				return tItem;
			}
		
		// Converts the image to a PNG bitmap and prompts the user to save.
		public function saveMovieClipAsBitmap(pObj:DisplayObject, pName:String="character", pScale:Number=1) : void
		{
			if(!pObj){ return; }
			
			var tRect:flash.geom.Rectangle = pObj.getBounds(pObj);
			var tBitmap:flash.display.BitmapData = new flash.display.BitmapData(tRect.width*pScale, tRect.height*pScale, true, 0xFFFFFF);
			
			var tMatrix:flash.geom.Matrix = new flash.geom.Matrix(1, 0, 0, 1, -tRect.left, -tRect.top);
			tMatrix.scale(pScale, pScale);
			
			tBitmap.draw(pObj, tMatrix);
			( new flash.net.FileReference() ).save( com.adobe.images.PNGEncoder.encode(tBitmap), pName+".png" );
		}
	}
}
