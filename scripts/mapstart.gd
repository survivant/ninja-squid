extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

var state = 0
func _on_Timer_timeout():
	if state == 0:
		set_opacity( 0 )
		get_node( "../Sprite1" ).set_opacity( 1 )
		state = 1
		get_node( "../Timer" ).set_wait_time( 1 )
		get_node( "../Timer" ).start()
	elif state == 1:
		get_node( "../Sprite1" ).queue_free()
		queue_free()
		global.emit_signal( "start_level" )
	
	pass # replace with function body
