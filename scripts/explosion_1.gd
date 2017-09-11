extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_node( "SamplePlayer" ).play( "bullet_explosion" )
	yield( get_node( "AnimationPlayer" ), "finished" )
	queue_free()
