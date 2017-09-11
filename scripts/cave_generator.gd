# based on the code by Michael Henderson: https://bitbucket.org/signalsin/


var numRooms = 2
var numRoomTries = 10
var extraConnectorChance = 20
var RoomSizeRange = [ Vector2( 10, 30 ) ]
var CorridorDimensions = Vector2( 2, 2 )
#var maxRoomSize = 5
var roomExtraSize = 0
var _rooms = []
var _regions = []

var worldSize

var tileSize = 16
var map

func _init( map, worldSize):
	
	self.worldSize = worldSize #Vector2( 100, 100 ) 
	self.map = map #get_node("./TileMap")

func generate():
	#_regions = get_viewport().get_rect().size
	
	_populate_world()
	_add_rooms()
	_add_corridors()
	return
	_set_tiles()

func _populate_world():
	for x in range( worldSize.x ):
		for y in range( worldSize.y ):
			map.set_cell( x, y, 15 )


func _add_rooms():
	var roomcount = 0
	for room in range( numRoomTries ):
		#var size = ( rand_range(1, ( 3 + roomExtraSize ) ) * 2 + 1 )# * tileSize
		var size
		var rectangularity = 0
		if RoomSizeRange.size() == 1:
			size = rand_rangei( RoomSizeRange[0].x, RoomSizeRange[0].y )
			rectangularity = rand_rangei( 0, roomExtraSize )
		else:
			size = RoomSizeRange[ roomcount ]
		
		var width = size
		var height = size
		
		if randi() % 2 == 1:
			width += rectangularity
		else:
			height += rectangularity

		#var x = ceil( rand_range(0, (worldSize.x - width) / 2) * 2 + 1 )
		var x = rand_rangei( 1, worldSize.x - width - 2 )
		#var y = ceil( rand_range(0, (worldSize.y - height) / 2) * 2 + 1 )
		var y = rand_rangei( 1, worldSize.y - height - 2 )
		
		var room = Rect2( x, y, width, height )
		var overlaps = false
		
		for other in _rooms:
			if room.intersects( other ):
				overlaps = true
				break
		
		if overlaps:
			continue
		
		_rooms.append(room)
	for room in _rooms:
		_carve_rect(room)



func _add_corridors():
	var nextRoomIndex = 1
	
	for room in _rooms:
		
		if nextRoomIndex > _rooms.size():
			continue
		elif nextRoomIndex == _rooms.size():
			nextRoomIndex = 0
		
		var nextRoom = _rooms[nextRoomIndex]
		
		var curCentre = _get_centre( room )
		var nextCentre = _get_centre(nextRoom)
		
		_add_horizontal_corridors( curCentre, Vector2( nextCentre.x, curCentre.y ) )
		_add_vertical_corridors( Vector2( nextCentre.x, curCentre.y ), nextCentre )
		
		nextRoomIndex += 1

func _add_horizontal_corridors(startPos, endPos):
	var horizontal = Rect2()
	if startPos.x < endPos.x:
		horizontal = Rect2(startPos.x , startPos.y, endPos.x - startPos.x + 1 , CorridorDimensions.y)
	else:
		horizontal = Rect2(endPos.x, endPos.y, startPos.x - endPos.x + 1, CorridorDimensions.y )
	_carve_rect(horizontal)

func _add_vertical_corridors(startPos, endPos):
	var vertical = Rect2()
	
	if startPos.y > endPos.y:
		#endPos.y = ceil( endPos.y ) #endPos.y = _round_to_tile(endPos.y, tileSize)
		#startPos.y = ceil( startPos.y ) #startPos.y = _round_to_tile(startPos.y, tileSize)
		vertical = Rect2(endPos.x, endPos.y, CorridorDimensions.x, startPos.y - endPos.y)
	else:
		vertical = Rect2(startPos.x, startPos.y, CorridorDimensions.x, endPos.y - startPos.y)
	
	_carve_rect(vertical)

func _set_tiles():
	return
	var x = 0
	var y = 0
	
	while x < worldSize.x / tileSize:
		while y < worldSize.y / tileSize:
			if map.get_cell(x, y) >= 0:
				map.set_cell(x, y, _get_tile_neighbours(x, y))
			y += 1
			
		y = 0
		x += 1

func _carve_rect(rect):
	var rectMapPos = rect.pos #map.world_to_map(rect.pos)
	var rectMapSize = rect.size #map.world_to_map(rect.size)
	
	var x = rectMapPos.x
	var y = rectMapPos.y
	
	while x < (rectMapSize.x + rectMapPos.x) :
		while y < (rectMapSize.y + rectMapPos.y):
			map.set_cell(x, y, -1)
			y += 1
		y = rectMapPos.y
		x += 1

func _get_centre(rect):
	var x = rect.pos.x + floor(rect.size.x / 2)
	var y = rect.pos.y + floor(rect.size.y / 2)
	return Vector2(x, y)

func _round_to_tile(x, base):
    return int(base * ceil(float(x)/base))

func _get_tile_neighbours(x, y):

	var sum = 0
	if map.get_cell(x, y - 1) >= 0:
		sum += 1
	if map.get_cell(x - 1, y) >= 0:
		sum += 2
	if map.get_cell(x, y + 1) >= 0:
		sum += 4
	if map.get_cell(x + 1, y) >= 0:
		sum += 8
	return sum



func rand_rangei( a, b ):
	return ( randi() % ( int( b ) - int( a ) + 2 ) ) + a
	pass






