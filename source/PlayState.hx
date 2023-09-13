package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.path.FlxPath;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import haxe.Log;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();

		var tileMap:FlxTilemap = createMap(32, 32);

		tileMap.scale.x = 0.2;
		tileMap.scale.y = 0.2;

		tileMap.screenCenter();

		add(tileMap);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function buildMaze(width:Int, height:Int) {}

	function createMap(width:Int, height:Int):FlxTilemap
	{
		var newMap:FlxTilemap = new FlxTilemap();
		newMap = new FlxTilemap();

		var gridCSV = FlxStringUtil.arrayToCSV([
			for (i in 0...height * width)
				FlxG.random.bool() ? 1 : 2
		], width);

		newMap.loadMapFromCSV(gridCSV, AssetPaths.tiles__png, 64, 64);

		// Manualy set the collision properties of our different tile types.
		newMap.setTileProperties(1, NONE);
		newMap.setTileProperties(2, ANY);
		newMap.setTileProperties(3, NONE);
		newMap.setTileProperties(4, NONE);

		return newMap;
	}
}
