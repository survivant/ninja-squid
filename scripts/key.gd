extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass



var iscaught = false
func _on_key_area_enter( area ):
	if iscaught: return
	if area.is_in_group( "coinbox" ):
		get_node( "SamplePlayer" ).play( "key" )
		iscaught = true
		global.has_key = true
		get_node( "AnimationPlayer" ).play( "caught" )
		yield( get_node( "AnimationPlayer" ), "finished" )
		queue_free()
