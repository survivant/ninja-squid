extends Area2D

onready var player = global.player #get_tree().get_nodes_in_group( "player" )[0]

func _ready():
	get_node( "Sprite" ).set_hidden( true )
	global.connect( "has_key", self, "open_door" )


func open_door():
	print( "opening door" )
	get_node( "Sprite" ).set_hidden( false )
	door_open = true
	
	
var door_open = false
var is_player = false
func _on_door_area_enter( area ):
	if not door_open: return
	if not area.is_in_group( "coinbox" ): return
	if is_player: return
	is_player = true
	player.set_fixed_process( false )
	var enemies = get_tree().get_nodes_in_group( "enemies" )
	for enemy in enemies:
		enemy.set_fixed_process( false )
	var bullets = get_tree().get_nodes_in_group( "bullet" )
	for b in bullets:
		b.queue_free()
	global.player.set_global_pos( get_global_pos() )
	get_node( "AnimationPlayer" ).play( "caught" )
	get_node( "SamplePlayer" ).play( "door" )
	yield( get_node( "AnimationPlayer" ), "finished" )
	global.finish_level()
	queue_free()
	pass # replace with function body
