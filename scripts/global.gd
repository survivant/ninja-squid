extends Node

var main = null
var coins = 0 setget _update_coins
var score = 0 setget _update_score
var has_key = false setget _update_key
var lives = 3 setget _update_lives
var energy = 100 setget _update_energy
var player = null
var curmapno = 0
var level_seeds = []
var camera = null

signal has_key
signal start_level

func _ready():
	#randomize()
	set_pause_mode( Node.PAUSE_MODE_PROCESS )
	# main scene
	var _root = get_tree().get_root()
	main = _root.get_child( _root.get_child_count() - 1 )
	
	# center screen
	var screen_size = OS.get_screen_size( 0 )
	var window_size = OS.get_window_size()
	OS.set_window_position( screen_size * 0.5 - window_size * 0.5 )
	
	# start process
	set_process( true )


func _process( delta ):
	# hit Esc to quit
	if Input.is_key_pressed( KEY_ESCAPE ):
		get_tree().quit()
	if player != null:
		var wr = weakref( player)
		if (!wr.get_ref()):
		    global.player = null
	
	
	
var coinsbar = null
func _update_coins( value ):
	coins = value
	if coins >= 100:
		_update_lives( lives + 1 )
		coins = 0
		if main != null:
			main.get_node( "hud_layer/hud/livesbar/AnimationPlayer" ).play( "cycle" )
	if coinsbar == null:
		coinsbar = get_tree().get_nodes_in_group( "coinsbar" )[0]
	coinsbar.set_text( "X %d" % [ coins ] )
	#print( "coins: ", coins )

var scorebar = null
func _update_score( value ):
	score = value
	if scorebar == null:
		scorebar = get_tree().get_nodes_in_group( "scorebar" )[0]
	scorebar.set_text( "SCORE %d" % [ score ] )


var keybar = null
func _update_key( value ):
	if keybar == null:
		keybar = get_tree().get_nodes_in_group( "keybar" )[0]
	has_key = value
	if has_key:
		emit_signal( "has_key" )
		keybar.set_hidden( false )
	else:
		keybar.set_hidden( true )





var energybar = null
func _update_energy( value ):
	energy = value
	if energybar == null:
		energybar = get_tree().get_nodes_in_group( "energybar" )[0]
	energybar.set_scale( Vector2( energy, 2.5 ) )
	if energy <= 0:
		energy = 100
		#lives -= 1
		_update_lives( lives - 1 )
		player.death()
		yield( player, "player_dead" )
		main.restart_level()
	




var livesbar = null
func _update_lives( value ):
	if livesbar == null:
		livesbar = get_tree().get_nodes_in_group( "livesbar" )[0]
	lives = value
	print( "lives: ", lives )
	livesbar.set_text( "X %d" % [ lives ] )
	if lives <= 0:
		if main != null: main.finish_game()



func finish_level():
	main.finish_level()
