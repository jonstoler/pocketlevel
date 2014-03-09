# pocketlevel specification

*version 0.2 - see CHANGELOG.md for more information*

**pocketlevel** is a file format for tile-based level layouts, intended for (but certainly not limited to!) game design.

pocketlevel uses a special plain-text syntax and organization to make levels lightweight, human-readable/editable, and portable.


## file specification

every level is stored in its own plain-text file. the extension `.lvl` is recommended but not required.

levels are comprised of 4 parts: **settings**, **layers**, **keys**, and **objects**.

levels are split into sections via *headers*. headers are defined via braces `{}`. braces are reserved characters. a header takes up its entire line.

for instance, to create a header named "main":

````
{main}
````

also note: any line that starts with `#` is considered a comment and parsers should treat it the same as an empty line. `#` is a reserved character.

### settings (optional)

each level has its own settings, but you can also specify global or default settings in a file named `settings.txt` in the same folder as the level itself.

you can have multiple `settings.txt`, depending on the file structure. "deeper" nested settings will take priority and overwrite other settings. this is best illustrated via example.

note that, for this example, settings are shown via parenthesis next to the file name. in a real example, they would be stored in the file as explained below.

````
/ [root]
	settings.txt (a = 1, b = 3)
	rootlvl.lvl
	subdir/
		settings.txt (a = 2, c = 4)
		sublvl.lvl
		anotherlvl.lvl (a = 3)
````

the settings would then be as follows:

````
   rootlvl.lvl -> a = 1, b = 3
    sublvl.lvl -> a = 2, b = 3, c = 4
anotherlvl.lvl -> a = 3, b = 3, c = 4
````

note that all settings are optional.

settings are defined using [toml][toml].

`settings.txt` takes raw toml. level files take toml written under the `settings` header, which is a reserved header. 

### layers (at least one required)

layers provide the actual layout of the level. each layer lives under its own header. layers closer to the end of the file are lower than layers closer to the top of the file; list them in "stack" order.

contents of layers are a string of characters representing different types of tiles. note that `.` is a reserved character that represents empty space. whitespace is allowed but ignored by the parser.

an example layer might look like:

````
{foreground}
..........
...o......
..........
.xxdwxx.x.
..........
````

layers are considered ongoing until a header is found or the file ends. empty lines are ignored. use `.` if you need blank space in your level.

if layers are not the same size, parsers should print a warning message. layers should be padded with blank space and aligned to the top left of the largest layer available.

### keys (optional)

a key specifies a translation table from character to integer representations for tiles.

keys allow you to take a layer and "convert" it to a list of integers. this is especially useful if you want to create and use a tilemap for your levels.

keys are stored in a file called `key.txt`.

keys follow the same rules of inheritance as settings - deeper nested keys override other keys.

each key item is defined by a character, followed by an arrow (`->`), followed by its numeric representation. every key item takes up an entire line. whitespace is allowed. multiple characters can map to the same integer.

multiple characters can map to the same integer on a single line by using commas, though this is optional. for instance:

`x, y, z -> 1`

for example, the level:

````
x.......x.
x.........
x..xx..xx.
x.........
xxxxxxxxxx
````

with the key:

````
. -> 0
x -> 1
````

can be converted to:

````
1000000010
1000000000
1001100110
1000000000
1111111111
````

### objects (optional)

objects provide flexibility for objects that cannot be represented by a simple tile. objects are defined in [toml][toml] under the `objects` header.

---

I recommend using [JavE][jave] as an editor. I may eventually write a more specialized editor with pocketlevel-specific features.

---

## full example

the following example has this file structure:

````
/ [root]
	settings.txt
	key.txt
	world_01/
		settings.txt
		key.txt
		level_01.lvl
````

#### /settings.txt
````
tileWidth = 32
tileHeight = 32
````

#### /key.txt
````
# empty
. -> 0

# floor
x -> 1

# pit
o -> 2

# exit
@ -> 3

# start position
+ -> 4
````

#### /world_01/settings.txt
````
tileset = "desert.png"
````

#### /world_01/key.txt
````
# cactus
& -> 18
````

#### /world_01/level_01.lvl
````
{fg}
.@xxxx..
..&..x.&
&..oxx..
..oxxxxx
..oxoo.+

{enemy}
..xxx...
....x...
..xxx...
....xxx.
....+...

{settings}
[level]
name = "Cactus Catastrophe"
difficulty = 3
targetTime = 19.48

[player]
startingHealth = 4
ammo = 16
````

[toml]: https://github.com/mojombo/toml
[jave]: http://jave.de/