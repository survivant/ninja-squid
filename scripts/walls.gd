extends TileMap

var wallgen_class = preload( "res://scripts/cave_generator.gd" )
var autotiler_class = preload( "res://scripts/autotiler.gd" )

var seaweeds = [ \
	preload( "res://scenes/seaweed_1.tscn" ), \
	preload( "res://scenes/seaweed_2.tscn" ), \
	preload( "res://scenes/bubbles.tscn" ) ]
var coin = preload( "res://scenes/coin.tscn" )


export(int) var numRoomTries = 10
export(int) var extraConnectorChance = 20
export(Vector2) var MapSize = Vector2( 80, 80 )
export(Vector2) var RoomSizeRange = Vector2( 10, 30 )
export(Vector2) var CorridorDimensions = Vector2( 2, 2 )

var wallgen

func _ready():
	_update()

func _update():
	seed( global.level_seeds[ global.curmapno ] )
	#randomize()
	wallgen = wallgen_class.new( self, MapSize )
	wallgen.numRoomTries = numRoomTries
	wallgen.extraConnectorChance = extraConnectorChance
	wallgen.RoomSizeRange = [ RoomSizeRange ]
	wallgen.CorridorDimensions = CorridorDimensions
	wallgen.generate()
	var autotiler = autotiler_class.new( self )
	
	_place_seaweeds()
	
	
	_place_player()
	pass







func _place_player():
	# find rooms in the edges of the map
	var minx = 100000
	var maxx = -100000
	var miny = 100000
	var maxy = -100000
	var minroom_x
	var maxroom_x
	var minroom_y
	var maxroom_y
	for w in wallgen._rooms:
		if w.pos.x < minx:
			minx = w.pos.x
			minroom_x = w
		if w.pos.x + w.size.x > maxx:
			maxx = w.pos.x + w.size.x
			maxroom_x = w
		if w.pos.y < miny:
			miny = w.pos.y
			minroom_y = w
		if w.pos.y + w.size.y > maxy:
			maxy = w.pos.y + w.size.y
			maxroom_y = w
		
	var playerpos = ( minroom_x.pos + minroom_x.size / 2 ) * get_cell_size()

	# place player in room
	var player = global.player #get_tree().get_nodes_in_group( "player" )[0]
	player.set_global_pos( get_pos() + playerpos ) 
	
	# FOR TESTING ENEMY
	
	
	# decide where to place the key and the door
	var possible_rooms = [ maxroom_x, minroom_y, maxroom_y ]
	var poskey = rand_rangei( 0, 2 )
	print( "poskey: ", poskey )
	var keyroom = possible_rooms[ poskey ]
	possible_rooms.remove( poskey )
	var posdoor = rand_rangei( 0, 1 )
	print( "posdoor: ", posdoor )
	var doorroom = possible_rooms[ posdoor ]
	
	var keypos = ( keyroom.pos + keyroom.size / 2 ) * get_cell_size()
	var key = preload( "res://scenes/key.tscn" ).instance()
	key.set_global_pos( get_pos() + keypos )
	add_child( key )
	
	var doorpos = ( doorroom.pos + doorroom.size / 2 ) * get_cell_size()
	var door = preload( "res://scenes/door.tscn" ).instance()
	door.set_global_pos( get_pos() + doorpos )
	add_child( door )
	
	
	
	
	# place enemies
	var enemyscn = preload( "res://scenes/enemy_1.tscn" )
	
	for w in wallgen._rooms:
		if w == minroom_x: continue
		var enemypos = ( w.pos + w.size / 2 ) * get_cell_size()
		enemypos += Vector2( -w.size.x / 2 + 1, 0 ) * get_cell_size()
		var enemy = enemyscn.instance()
		enemy.set_pos( get_pos() + enemypos )
		add_child( enemy )
	
	






func _place_seaweeds():
	var csize = get_cell_size()
	var bottom_tiles = _get_bottom_tiles()
	for b in bottom_tiles:
		var r = randf()
		var type = -1 # nothing
		if r > 0.5 and r <= 0.6:
			var obj = seaweeds[0].instance()
			obj.set_pos( map_to_world( b ) + Vector2( csize.x / 2, csize.y ) )
			if randf() > 0.5:
				obj.set_scale( Vector2( -1, 1 ) )
			add_child( obj )
		elif r > 0.6 and r < 0.9:
			var obj = seaweeds[1].instance()
			obj.set_pos( map_to_world( b ) + Vector2( csize.x / 2, csize.y ) )
			if randf() > 0.5:
				obj.set_scale( Vector2( -1, 1 ) )
			add_child( obj )
		elif r > 0.9:
			var obj = seaweeds[2].instance()
			obj.set_pos( map_to_world( b ) + Vector2( csize.x / 2, csize.y ) )
			if randf() > 0.5:
				obj.set_scale( Vector2( -1, 1 ) )
			add_child( obj )
		if r < 0.6:
			var obj = coin.instance()
			obj.set_pos( map_to_world( b ) + Vector2( csize.x / 2, csize.y ) )
			add_child( obj )
	
	
	var top_tiles = _get_top_tiles()
	for b in top_tiles:
		var r = randf()
		var type = -1 # nothing
		if r > 0.5 and r <= 0.6:
			var obj = seaweeds[0].instance()
			obj.set_pos( map_to_world( b ) + Vector2( csize.x / 2, 0 ) )
			if randf() > 0.5:
				obj.set_scale( Vector2( -1, -1 ) )
			else:
				obj.set_scale( Vector2( 1, -1 ) )
			add_child( obj )
		elif r > 0.6 and r < 1:
			var obj = seaweeds[1].instance()
			obj.set_pos( map_to_world( b ) + Vector2( csize.x / 2, 0 ) )
			if randf() > 0.5:
				obj.set_scale( Vector2( -1, -1 ) )
			else:
				obj.set_scale( Vector2( 1, -1 ) )
			add_child( obj )
	
	var right_tiles = _get_side_tiles_right()
	for b in right_tiles:
		var r = randf()
		var type = -1 # nothing
		if r > 0.9 and r < 1:
			var obj = seaweeds[1].instance()
			obj.set_pos( map_to_world( b ) + \
				Vector2( 0, csize.y / 2 ) )
			if randf() > 0.5:
				obj.set_scale( Vector2( -1, 1 ) )
			obj.set_rotd( -90 )
			add_child( obj )
	
	var left_tiles = _get_side_tiles_left()
	for b in left_tiles:
		var r = randf()
		var type = -1 # nothing
		if r > 0.9 and r < 1:
			var obj = seaweeds[1].instance()
			obj.set_pos( map_to_world( b ) + \
				Vector2( csize.x, csize.y / 2 ) )
			if randf() > 0.5:
				obj.set_scale( Vector2( -1, 1 ) )
			obj.set_rotd( 90 )
			add_child( obj )
	
	for type in range( seaweeds.size() ):
		pass
	pass

func _get_bottom_tiles():
	var bottom_tiles = []
	var tilerect = self.get_used_rect()
	for x in range( tilerect.pos.x, tilerect.pos.x + tilerect.size.x ):
		for y in range( tilerect.pos.y, tilerect.pos.y + tilerect.size.y ):
			var curcell = get_cell( x, y )
			if curcell != -1: continue
			if get_cell( x, y + 1 ) >= 0:
				bottom_tiles.append( Vector2( x, y ) )
	return bottom_tiles
func _get_top_tiles():
	var bottom_tiles = []
	var tilerect = self.get_used_rect()
	for x in range( tilerect.pos.x, tilerect.pos.x + tilerect.size.x ):
		for y in range( tilerect.pos.y, tilerect.pos.y + tilerect.size.y ):
			var curcell = get_cell( x, y )
			if curcell != -1: continue
			if get_cell( x, y - 1 ) >= 0:
				bottom_tiles.append( Vector2( x, y ) )
	return bottom_tiles
func _get_side_tiles_right():
	var right_tiles = []
	var tilerect = self.get_used_rect()
	for x in range( tilerect.pos.x, tilerect.pos.x + tilerect.size.x ):
		for y in range( tilerect.pos.y, tilerect.pos.y + tilerect.size.y ):
			var curcell = get_cell( x, y )
			if curcell != -1: continue
			if get_cell( x - 1, y ) >= 0:
				right_tiles.append( Vector2( x, y ) )
	return right_tiles
func _get_side_tiles_left():
	var right_tiles = []
	var tilerect = self.get_used_rect()
	for x in range( tilerect.pos.x, tilerect.pos.x + tilerect.size.x ):
		for y in range( tilerect.pos.y, tilerect.pos.y + tilerect.size.y ):
			var curcell = get_cell( x, y )
			if curcell != -1: continue
			if get_cell( x + 1, y ) >= 0:
				right_tiles.append( Vector2( x, y ) )
	return right_tiles



func rand_rangei( a, b ):
	return ( randi() % ( int( b ) - int( a ) + 1 ) ) + a
	pass