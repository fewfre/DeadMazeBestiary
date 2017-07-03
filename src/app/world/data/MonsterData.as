package app.world.data
{
	import app.data.*;
	import flash.display.*;
	import flash.geom.*;
	
	public class MonsterData extends ItemData
	{
		// Storage
		public var poses		: Array;
		
		// Constructor
		public function MonsterData(pID:String) {
			super({ id:pID });
			
			poses = [];
		}
	}
}