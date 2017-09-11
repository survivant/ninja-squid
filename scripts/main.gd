extends Node2D


var state = 0
var cur_map = ""
onready var anim = get_node( "fadelayer/fadeanim" )
onready var mapnode = get_node( "map" )

onready var songs = [ \
	preload( "res://music/intro.ogg" ), \
	preload( "res://music/level.ogg" ) ]


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	change_map( "res://scenes/intro.tscn" )
	#change_map( "res://scenes/testmap.tscn" )
	#start_game()
	pass



func change_map( mapname ):
	# fade out
	anim.play( "fadeout" )
	yield( anim, "finished" )
	# clear existing map
	get_tree().set_pause( true )
	for c in mapnode.get_children():
		c.queue_free()
	get_tree().set_pause( false )
	# load new map
	print( "Changing map to: ", mapname )
	if mapname == "res://scenes/intro.tscn" or \
		mapname == "res://scenes/endscene.tscn" or \
		mapname == "res://scenes/gameover.tscn":
		get_node( "hud_layer/hud" ).set_hidden( true )
	else:
		get_node( "hud_layer/hud" ).set_hidden( false )
	var map = load( mapname ).instance()
	mapnode.add_child( map )
	
	#get_tree().set_pause( true )
	# fade in
	anim.play( "fadein" )
	yield( anim, "finished" )
	# start
	#get_tree().set_pause( false )
	if mapname == "res://scenes/intro.tscn" or \
		mapname == "res://scenes/endscene.tscn" or \
		mapname == "res://scenes/gameover.tscn":
		get_node( "player" ).stop()
		get_node( "player" ).set_stream( songs[0] )
		get_node( "player" ).play()
	else:
		get_node( "player" ).stop()
		get_node( "player" ).set_stream( songs[1] )
		get_node( "player" ).play()
	pass




func start_game():
	global.level_seeds = []
	randomize()
	for n in range( 6 ):
		global.level_seeds.append( randi()%100 )
	global.lives = 3
	global.energy = 100
	global.has_key = false
	global.score = 0
	global.coins = 0
	global.curmapno = 0
	change_map( "res://scenes/testmap.tscn" )

func restart_level():
	global.energy = 100
	global.has_key = false
	change_map( "res://scenes/testmap.tscn" )
	pass

func finish_level():
	global.energy = 100
	global.has_key = false
	global.curmapno += 1
	if global.curmapno == global.level_seeds.size():
		change_map( "res://scenes/endscene.tscn" )
	else:
		change_map( "res://scenes/testmap.tscn" )
	pass

func finish_game():
	change_map( "res://scenes/gameover.tscn" )
	#change_map( "res://scenes/intro.tscn" )
	pass


	