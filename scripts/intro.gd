extends Node2D


func _ready():
	if global.camera != null:
		global.camera.follow_player = false
		global.camera.set_pos( Vector2( 0, 0 ) )
		global.camera.align()
	set_process( true )


func _process( delta ):
	# hit Esc to quit
	#if Input.is_key_pressed( KEY_ESCAPE ):
	#	get_tree().quit()
	if Input.is_action_pressed( "btn_fire" ):
		global.main.start_game()