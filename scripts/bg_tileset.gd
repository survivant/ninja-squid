extends TileMap

var wallgen_class = preload( "res://scripts/cave_generator.gd" )
var autotiler_class = preload( "res://scripts/autotiler.gd" )


export(int) var numRoomTries = 10
export(int) var extraConnectorChance = 20
export(Vector2) var MapSize = Vector2( 80, 80 )
export(Vector2) var RoomSizeRange = Vector2( 10, 30 )
export(Vector2) var CorridorDimensions = Vector2( 2, 2 )

func _ready():
	#seed(1)
	randomize()
	var wallgen = wallgen_class.new( self, MapSize )
	wallgen.numRoomTries = numRoomTries
	wallgen.extraConnectorChance = extraConnectorChance
	wallgen.RoomSizeRange = [ RoomSizeRange ]
	wallgen.CorridorDimensions = CorridorDimensions
	wallgen.generate()
	
	var autotiler = autotiler_class.new( self )
