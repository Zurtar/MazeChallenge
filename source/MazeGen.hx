import PlayState;
import flixel.tile.FlxTilemap;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxStringUtil;
import maze.DepthFirst;

class MazeGen
{
	static var map:FlxTilemap;

	public static function buildMazeFromLib(width:Int, height:Int):FlxTilemap
	{
		map = new FlxTilemap();

		// Use the maze library to build the maze and then convert it to a flat array
		var flatGrid = FlxArrayUtil.flatten2DArray(DepthFirst.make(width, height));

		// Convert it too our tileSet index by adding 1 to every value
		for (i in 0...flatGrid.length)
		{
			flatGrid[i] += 1;
		}

		// set first pathway in list to START
		flatGrid[flatGrid.indexOf(PATHWAY)] = START;

		// set last pathway in lis to goal
		flatGrid[flatGrid.lastIndexOf(PATHWAY)] = GOAL;

		// Convert our array representing our map to an CSV and import is as a tileMap
		var gridCSV = FlxStringUtil.arrayToCSV(flatGrid, Math.floor(Math.sqrt(flatGrid.length)));
		map.loadMapFromCSV(gridCSV, AssetPaths.tiles__png, 64, 64);

		// Setup tile collision properties
		map.setTileProperties(1, NONE);
		map.setTileProperties(2, ANY);
		map.setTileProperties(3, NONE);
		map.setTileProperties(4, NONE);

		return map;
	}
}
