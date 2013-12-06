package pocketlevel
{
import flash.utils.ByteArray;
public class PocketLevel
{
	private static var _defaults:Object    = {};
	private static var _keys:Object = {};

	public var layers:Object   = {};
	public var settings:Object = {};
	public var objects:Object  = {};

	/*
		NOTE: this is a work-in-progress!

		It's perfectly functional but may require reorganization or refactoring.
	*/
	public function PocketLevel(file:Class = null):void
	{
		settings = mergeObjects(_defaults, settings);
		if(file != null){
			loadLevel(file);
		}
	}

	public function loadLevel(file:Class):void
	{
		var contents:String = read(file);

		var lines:Array = contents.split("\n");
		var currentHeader:String = "";

		var line:String;
		for(var i:uint = 0; i < lines.length; i++){
			line = lines[i];

			// trim line, strip comments
			line = line.replace(/^\s+|\s+$/g, '');
			line = line.replace(/#.*/, '');

			// whitespace line or comment, ignore
			if(line == ""){ continue; }

			if(line.indexOf("{") == 0){ // new heading
				currentHeader = line.substring(1, line.length - 1);
			}

			if(currentHeader == "settings"){
				var allSettings:Array = [];
				for(var j:uint = i; j < lines.length; j++){
					if(lines[j].indexOf("{") == 0){
						if(j > i){ break; }
						else { continue; }
					}
					allSettings.push(lines[j]);
				}

				settings = TOML.parse(allSettings.join("\n"));
				settings = mergeObjects(_defaults, settings);
				i += allSettings.length;
			} else if(currentHeader == "objects"){
				var allObjects:Array = [];
				for(var k:uint = i; k < lines.length; k++){
					if(lines[k].indexOf("{") == 0){
						if(k > i){ break; }
						else { continue; }
					}
					allObjects.push(lines[k]);
				}

				objects = TOML.parse(allObjects.join("\n"));
				i += allObjects.length;
			} else if(currentHeader != "") { // it's a layer
				layers[currentHeader] = [];
				for(var n:uint = i; n < lines.length; n++){
					if(n > i){
						if(lines[n].indexOf("{") == 0){ break; }

						var l:String = lines[n].replace(/\s/g, "");
						if(l == ""){ continue; }

						layers[currentHeader].push(l.split(""));
					}
				}

				i += layers[currentHeader].length;
			}
		}
	}

	private static function parseKeys(keys:String):Object
	{
		var lines:Array = keys.split("\n");
		var obj:Object = {};

		var line:String;
		for(var i:uint = 0; i < lines.length; i++){
			line = lines[i];

			// trim line, strip comments
			line = line.replace(/^\s+|\s+$/g, '');
			line = line.replace(/#.*/, '');

			if(line == ""){ continue; }

			// trim whitespace
			line = line.replace(/\s/g, "");

			var components:Array = line.split("->");
			obj[components[0]] = Number(components[1]);
		}

		return obj;
	}

	public function get layerNames():Array
	{
		var names:Array = [];

		for(var layer:String in layers){
			names.push(layer);
		}

		return names;
	}

	public function getTextRepresentation(layer:String):String
	{
		var str:String = "";
		if(layers.hasOwnProperty(layer)){
			var tiles:Array = layers[layer];
			for(var i:uint = 0; i < tiles.length; i++){
				str += tiles[i].join("");
				if(i < tiles.length - 1){ str += "\n"; }
			}
		}

		return str;
	}

	public function getKeyedRepresentation(layer:String):String
	{
		var str:String = "";
		if(layers.hasOwnProperty(layer)){
			var tiles:Array = layers[layer];
			for(var i:uint = 0; i < tiles.length; i++){
				for(var j:uint = 0; j < tiles[i].length; j++){
					if(_keys.hasOwnProperty(tiles[i][j])){
						str += _keys[tiles[i][j]];
					}
				}
				str += "\n";
			}
		}
		return str;
	}

	public function get keyedTranslation():Object
	{
		var obj:Object = layers;

		for(var layer:String in obj){
			for(var i:uint = 0; i < obj[layer].length; i++){
				for(var j:uint = 0; j < obj[layer][i].length; j++){
					var prop:String = obj[layer][i][j];
					if(_keys.hasOwnProperty(prop)){
						obj[layer][i][j] = _keys[prop];
					}
				}
			}
		}

		return obj;
	}

	public static function loadKeys(file:Class):void
	{
		var newKeys:Object = parseKeys(read(file));
		_keys = mergeObjects(_keys, newKeys);
	}

	public static function loadDefaults(file:Class):void
	{
		var contents:String = read(file);

		var newSettings:Object = TOML.parse(contents);
		_defaults = mergeObjects(_defaults, newSettings);
	}

	private static function mergeObjects(read:Object, write:Object):Object
	{
		for(var prop:String in read){
			if(typeof read[prop] == "object"){
				if(write.hasOwnProperty(prop)){
					read[prop] = mergeObjects(read[prop], write[prop]);
				}
			}
			write[prop] = read[prop];
		}
		return write;
	}

	private static function read(file:Class):String
	{
		var bytes:ByteArray = new file;
		return bytes.readUTFBytes(bytes.length);
	}
}
}
