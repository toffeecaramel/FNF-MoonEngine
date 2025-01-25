package moon.obj.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.ui.FlxButton;
import flixel.text.FlxText;

class TooltipButton extends FlxGroup
{
	private var _btn:FlxSprite;
	private var _dialogue:FlxSprite;
	private var _descText:FlxText;

	public var onClick:Void->Void;
	public function new(x:Float = 0, y:Float = 0, image:flixel.graphics.FlxGraphic, tooltip:String, ?onClick:Void->Void)
	{
		super();
		this.onClick = onClick;

		_btn = new FlxButton(x, y, null, onClick);
		_btn.loadGraphic(image);
		_btn.setGraphicSize(image.width / 2, image.height / 2);
		_btn.updateHitbox();
		add(_btn);

		_dialogue = new FlxSprite(x, y - 100).loadGraphic(Paths.image("editors/dialogue"));
		_dialogue.antialiasing = false;
		_dialogue.scale.set(3, 3);
		_dialogue.updateHitbox();
		_dialogue.x = (x + _dialogue.width) / 2.5;
		_dialogue.alpha = 0.0001;
		add(_dialogue);

		_descText = new FlxText(x + 20, _dialogue.y + 7, _dialogue.width - 20, tooltip);
		_descText.setFormat(Paths.fonts('vcr.ttf'), 18, LEFT);
		_descText.alpha = 0.0001;
		_descText.color = flixel.util.FlxColor.BLACK;
		_descText.x = (_dialogue.x) + 10;
		add(_descText);
	}

	private var _timer:Float;
	public var descriptionDelay:Float = 0.7;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(FlxG.mouse.overlaps(_btn))
		{
			_timer += elapsed;
			_btn.alpha = 1;

			(_timer >= descriptionDelay) ? _displayDialogue(elapsed, [_dialogue, _descText]) : _hideDialogue(elapsed, [_dialogue, _descText]);
		}
		else {_timer = 0; _hideDialogue(elapsed, [_dialogue, _descText]); _btn.alpha = 0.7;}
	}

	private function _displayDialogue(elapsed:Float, _objects:Array<FlxSprite>):Void
	{
		for(_obj in _objects)
			if(_obj.alpha <= 1) _obj.alpha += elapsed * 2;
	}

	private function _hideDialogue(elapsed:Float, _objects:Array<FlxSprite>):Void
	{
		for(_obj in _objects)
			if(_obj.alpha >= 0.0001) _obj.alpha -= elapsed * 2;
	}
}