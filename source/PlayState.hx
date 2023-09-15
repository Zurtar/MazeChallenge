package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.path.FlxPath;
import flixel.text.FlxText;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDirection;
import flixel.util.FlxStringUtil;
import haxe.Log;
import haxe.ds.GenericStack;
import haxe.ds.GenericStack;
import maze.DepthFirst;
import openfl.display.Tilemap;

using flixel.util.FlxSpriteUtil;

// imported from my previous project, just a enum to represent our tile types
enum abstract TileType(Int) to Int
{
	var PATHWAY = 1;
	var WALL = 2;
	var GOAL = 3;
	var START = 4;
}

enum abstract Direction(Int) to Int
{
	var UP = 0;
	var DOWN = 1;
	var LEFT = 2;
	var RIGHT = 3;
}

class PlayState extends FlxState
{
	public static var tileMap:FlxTilemap = new FlxTilemap();

	var player:Player;

	override public function create()
	{
		super.create();

		reset();
		var controlText = new FlxText(5, 5, -1, "G: Creates a New Map\nF: Toggles Auto Mode", 16);

		add(controlText);
		add(player);
	}

	override public function update(elapsed:Float)
	{
		// Get the tile type that the player is currently on. (There's a better way to do this)
		var tileType = PlayState.tileMap.getTileByIndex(PlayState.tileMap.getTileIndexByCoords(player.getPosition()));

		if (FlxG.keys.justPressed.G || tileType == GOAL)
		{
			FlxTween.globalManager.cancelTweensOf(player);
			reset();
		}

		FlxG.collide(tileMap, player);

		super.update(elapsed);
	}

	public function reset()
	{
		remove(tileMap);
		tileMap = MazeGen.buildMazeFromLib(33, 33);

		tileMap.scale.x = 0.2;
		tileMap.scale.y = 0.2;

		tileMap.screenCenter();

		// Get the top left corner of the start tile (in world position)
		var worldStartPoint = tileMap.getTileCoordsByIndex(tileMap.getTileInstances(START)[0], true);
		var worldGoalPoint = tileMap.getTileCoordsByIndex(tileMap.getTileInstances(GOAL)[0], true);

		player = new Player(0, 0);
		player.makeGraphic(Math.floor(tileMap.scaledTileWidth) - 1, Math.floor(tileMap.scaledTileWidth) - 1, FlxColor.RED);
		player.setPosition(worldStartPoint.x, worldStartPoint.y);

		var path = tileMap.findPath(worldStartPoint, worldGoalPoint, LINE, NONE);

		player.setOptimalPath(path);

		// Stops the autopath and kills any movement.
		player.path = null;
		player.velocity.x = 0;
		player.velocity.y = 0;

		player.moveCount = 0;
		add(tileMap);
	}
}

class Player extends FlxSprite
{
	public var moveCount:Int = 0;

	// stores the correct path for the current level.
	var optimalPath:Array<FlxPoint> = [];

	var autoMode:Bool = false;

	override public function new(x:Float, y:Float)
	{
		super(x, y);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var newPos = FlxPoint.weak(0, 0);
		var mousePos = FlxG.mouse.getPosition();
		var validMove = PlayState.tileMap.getBounds().containsPoint(mousePos);

		if (FlxG.keys.justPressed.F)
		{
			setPosition(optimalPath[0].x - (width / 2), optimalPath[0].y - (height / 2));
			// either have moveCount update on point change or find a way to tie into paths update method.
			path = new FlxPath();
			path.start(optimalPath, 100);
			moveCount = optimalPath.length;
			return;
		}

		if (optimalPath != null && optimalPath[optimalPath.length - 1] == getPosition())
		{
			path = null;
		}

		// Gets the tile type at the possible new position;
		var tileType = PlayState.tileMap.getTileByIndex(PlayState.tileMap.getTileIndexByCoords(mousePos));
		if (tileType != WALL && validMove && mousePos.equals(getPosition()) == false && getHitbox().containsPoint(mousePos))
		{
			newPos.x = mousePos.x - (width / 2);
			newPos.y = mousePos.y - (height / 2);

			FlxTween.tween(this, {x: newPos.x, y: newPos.y}, 0.01);
		}

		// Return the point back to the pool.
		newPos.put();
		mousePos.put();
	}

	// this might be pass by reference, so careful.
	public function setOptimalPath(_path:Array<FlxPoint>)
	{
		optimalPath = _path;
	}
}

class MazeGen
{
	static var map:FlxTilemap;

	// doesn't work -- needs to be point based then translate that to the grid.
	public static function generateMaze(_map:FlxTilemap):FlxTilemap
	{
		var visitedList:Array<Int> = [];
		var stack:GenericStack<Int> = new GenericStack<Int>();

		map = _map;

		stack.add(0);

		while (!stack.isEmpty())
		{
			var tile = stack.pop();

			// mark tile as visited by pushing its index to the list
			if (visitedList.contains(tile) == false)
				visitedList.push(tile);

			var neighbors = getNeighbors(tile);

			// Get a random inbounds unvisited neighbors

			neighbors = neighbors.filter(x -> x != -1).filter(x -> visitedList.contains(x) == false);
			var selectedNeighbor = FlxG.random.getObject(neighbors);
			Log.trace(selectedNeighbor);

			// cell is done! move on
			if (selectedNeighbor == -1 || neighbors.length == 0)
				continue;

			// push cell to stack
			stack.add(tile);

			// Remove the wall between this cell and the next one.
			// map.setTileByIndex(tile, PATHWAY);
			map.setTileByIndex(selectedNeighbor, PATHWAY);

			visitedList.push(selectedNeighbor);
			stack.add(selectedNeighbor);
		}
		return map;
	}

	public static function getNeighbors(tile:Int):Array<Int>
	{
		var worldPos = map.getTileCoordsByIndex(tile);

		// U,D,L,R, -1 on not found
		return [
			map.getTileIndexByCoords(worldPos.addNew(FlxPoint.weak(0, -map.scaledTileHeight))),
			map.getTileIndexByCoords(worldPos.addNew(FlxPoint.weak(0, map.scaledTileHeight))),
			map.getTileIndexByCoords(worldPos.addNew(FlxPoint.weak(-map.scaledTileWidth, 0))),
			map.getTileIndexByCoords(worldPos.addNew(FlxPoint.weak(map.scaledTileWidth, 0))),
		];
	}

	public static function buildMazeFromLib(width:Int, height:Int):FlxTilemap
	{
		map = new FlxTilemap();

		// Use the maze library to build the maze and then convert it to a flat array
		var flatGrid = FlxArrayUtil.flatten2DArray(DepthFirst.make(width, height));

		// Convert it too our tileSet index
		for (i in 0...flatGrid.length)
		{
			flatGrid[i] = flatGrid[i] == 0 ? PATHWAY : WALL;
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
