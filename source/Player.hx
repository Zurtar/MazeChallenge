import PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.path.FlxPath;
import flixel.tweens.FlxTween;

class Player extends FlxSprite
{
	// stores the correct path for the current level.
	var optimalPath:Array<FlxPoint> = [];

	override public function new(x:Float, y:Float)
	{
		super(x, y);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// Enqueue the solved maze path!
		if (FlxG.keys.justPressed.F)
		{
			setPosition(optimalPath[0].x - (width / 2), optimalPath[0].y - (height / 2));

			// create and start this sprites path
			path = new FlxPath();
			path.start(optimalPath, 250);

			return;
		}

		// if we're at the end of the path, kill it
		if (optimalPath[optimalPath.length - 1] == getPosition())
		{
			path = null;
		}

		// Build a temp new posistion and grab mouse position
		var newPos = FlxPoint.weak(0, 0);
		var mousePos = FlxG.mouse.getPosition();
		var validMove = PlayState.tileMap.getBounds().containsPoint(mousePos);

		// Gets the tile type at the possible new position;
		var tileType = PlayState.tileMap.getTileByIndex(PlayState.tileMap.getTileIndexByCoords(mousePos));

		// verify new posistion is valid and different than current POS
		if (tileType != WALL && validMove && mousePos.equals(getPosition()) == false && getHitbox().containsPoint(mousePos))
		{
			// convert to midpoint
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
