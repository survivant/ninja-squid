extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_node( "AnimationPlayer" ).connect( "finished", self, "finished" )
	get_node( "SamplePlayer" ).play( "bullet_explosion" )
	

func finished():
	queue_free()
