package;

import MazeGen;
import Player;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

// TileMap that helps us convert from an index of a tile in our png to a tileMap index
enum abstract TileType(Int) to Int
{
	var PATHWAY = 1;
	var WALL = 2;
	var GOAL = 3;
	var START = 4;
}

class PlayState extends FlxState
{
	public static var tileMap:FlxTilemap = new FlxTilemap();

	var player:Player;

	override public function create()
	{
		super.create();

		player = new Player(0, 0);

		// some helper text to explain controls
		var controlText = new FlxText(5, 5, -1, "G: Creates a New Map\nF: Toggles Auto Mode", 16);

		// resets game state creates map... etcs
		reset();

		add(controlText);
		add(player);
	}

	override public function update(elapsed:Float)
	{
		// Get the tile type that the player is currently on. (There's a better way to do this)
		var tileType = tileMap.getTileByIndex(tileMap.getTileIndexByCoords(player.getPosition()));

		if (FlxG.keys.justPressed.G || tileType == GOAL)
		{
			// stop all movement and reset
			FlxTween.globalManager.cancelTweensOf(player);
			reset();
		}

		// check for player collision with the tileMap
		FlxG.collide(tileMap, player);

		super.update(elapsed);
	}

	public function reset()
	{
		remove(tileMap);
		tileMap = MazeGen.buildMazeFromLib(33, 33);

		// scale down to fit screen
		tileMap.scale.x = 0.2;
		tileMap.scale.y = 0.2;

		tileMap.screenCenter();

		// Get the top left corner of the start tile (in world position)
		var worldStartPoint = tileMap.getTileCoordsByIndex(tileMap.getTileInstances(START)[0], false);
		var worldGoalPoint = tileMap.getTileCoordsByIndex(tileMap.getTileInstances(GOAL)[0], false);

		// Create the player and set the graphic to match the tile height/width6
		player.makeGraphic(Math.floor(tileMap.scaledTileWidth) - 1, Math.floor(tileMap.scaledTileHeight) - 1, FlxColor.RED);

		// set player position back to start
		player.setPosition(worldStartPoint.x, worldStartPoint.y);

		// convert to a midpoint;
		worldStartPoint = worldStartPoint.add(tileMap.scaledTileWidth / 2, tileMap.scaledTileHeight / 2);
		worldGoalPoint = worldGoalPoint.add(tileMap.scaledTileWidth / 2, tileMap.scaledTileHeight / 2);

		// find the path to solve the maze and pass it to the player for pathfinding
		var path = tileMap.findPath(worldStartPoint, worldGoalPoint, LINE, NONE);
		player.setOptimalPath(path);

		// Stops the autopath and kills any movement.
		player.path = null;
		player.velocity.x = 0;
		player.velocity.y = 0;

		add(tileMap);
	}
}
