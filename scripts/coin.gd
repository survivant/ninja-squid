extends Sprite


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

var iscaught = false
func _on_Area2D_area_enter( area ):
	if iscaught: return
	if area.is_in_group( "coinbox" ):
		iscaught = true
		global.player.samples.play( "coin" )
		global.coins += 1
		global.score += 100
		get_node( "AnimationPlayer" ).play( "coin" )
		yield( get_node( "AnimationPlayer" ), "finished" )
		queue_free()
