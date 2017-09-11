extends Sprite


func _ready():
	get_node( "AnimationPlayer" ).set_speed( rand_range( 0.05, 0.2 ) )
	
	get_node( "AnimationPlayer" ).play( "ripple" )
	#get_node( "AnimationPlayer" ).seek( randf() )
