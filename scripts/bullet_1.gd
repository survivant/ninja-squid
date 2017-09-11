extends Area2D

var dir = Vector2()
var vel = 250 * Vector2( 1, 1 )

func _ready():
	get_node( "Sprite" ).set_rot( PI/2 + dir.angle() - PI )
	set_fixed_process( true )

func _fixed_process( delta ):
	var curpos = get_pos()
	curpos += dir * vel * delta
	set_pos( curpos )




func _on_bullet_1_area_enter( area ):
	if area.is_in_group( "player_hitbox" ):
		#print( "player_hit" )
		area.get_parent().hit( dir )
		_explosion()
		queue_free()
		
	elif area.is_in_group( "swordhit" ):
		_explosion()
		queue_free()



func _on_bullet_1_body_enter( body ):
	#print( "body: ", body )
	_explosion()
	queue_free()

func _explosion():
	var n = preload( "res://scenes/explosion_1.tscn" ).instance()
	n.set_global_pos( get_global_pos() )
	get_parent().add_child( n )
