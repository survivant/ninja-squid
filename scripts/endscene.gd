extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	if global.camera != null:
		global.camera.follow_player = false
		global.camera.set_pos( Vector2( 0, 0 ) )
		global.camera.align()
	set_process( true )


func _process(delta):
	if Input.is_action_pressed( "btn_fire" ):
		global.main.change_map( "res://scenes/intro.tscn" )
