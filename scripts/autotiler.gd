
var tilemap

func _init( tilemap ):
	self.tilemap = tilemap
	_autotile()

func _autotile():
	var tilerect = tilemap.get_used_rect()
	#print( tilerect )
	
	for x in range( tilerect.pos.x + 1, tilerect.pos.x + tilerect.size.x - 1 ):
		for y in range( tilerect.pos.y + 1, tilerect.pos.y + tilerect.size.y - 1 ):
			var curcell = tilemap.get_cell( x, y )
			if curcell == -1: continue
			var score = 0
			if tilemap.get_cell( x, y - 1 ) >= 0: score += 1 # north
			if tilemap.get_cell( x - 1, y ) >= 0: score += 2 # west
			if tilemap.get_cell( x + 1, y ) >= 0: score += 4 # east
			if tilemap.get_cell( x, y + 1) >= 0: score += 8 # south
			tilemap.set_cell( x, y, score )

