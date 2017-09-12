extends KinematicBody2D

enum STATES { WANDER, CHASE, FIRE }
var state_cur
var state_nxt = STATES.WANDER
var energy = 3
onready var samples = get_node( "samples" )

onready var player = global.player #get_tree().get_nodes_in_group( "player" )[-1]

onready var anim = get_node( "rotate/anim" )
var anim_cur = ""
var anim_nxt = "idle"
var anim_repeat = false

const GRAVITY = 200
const MAX_VEL = 50
var vel = Vector2( 0, 0 )

onready var rotate = get_node( "rotate" )
var dir = 1

onready var raycast = get_node( "rotate/raycast" )
onready var raycast_wall = get_node( "rotate/raycast_wall" )
onready var vision = get_node( "rotate/vision" )

func _ready():
	raycast.add_exception( self )
	raycast_wall.add_exception( self )
	global.connect( "start_level", self, "_start" )
	#yield( global, "start_level" )
	#set_fixed_process( true )
func _start():
	set_fixed_process( true )


func _player_on_vision():
	var bodies = vision.get_overlapping_bodies()
	var player_in_area = false
	for body in bodies:
		if body == global.player: #.is_in_group( "player" ):
			player_in_area = true
			return true
	return false
	
func _player_on_sight():
	#print( "enemy: this tis the player", player )
	if player == null: return false
	var wr = weakref(player)
	if (!wr.get_ref()):
	    return false
	#else:
	#    # not freed
	var space_state = get_world_2d().get_direct_space_state()
	var results = space_state.intersect_ray( get_global_pos(), player.get_global_pos(), [ self ] )
	if not results.empty():
		if results["collider"] == player:
			return true
	return false

func _end_of_ground():
	if ( not raycast.is_colliding() ) or ( raycast_wall.is_colliding() ):
		return true
	return false

var flashtimer = 0.05
func _fixed_process( delta ):
	state_cur = state_nxt
	if state_cur == STATES.WANDER:
		_state_wander( delta )
	elif state_cur == STATES.CHASE:
		_state_chace( delta )
	elif state_cur == STATES.FIRE:
		_state_fire( delta )
	
	if anim_cur != anim_nxt or anim_repeat:
		anim_cur = anim_nxt
		anim.play( anim_cur )
		anim_repeat = false
	
	var currot = rotate.get_scale().x
	if currot != dir:
		rotate.set_scale( Vector2( dir, 1 ) )
	
	if is_dying:
		hit_timer -= delta
		if hit_timer <= 0:
			is_dying = false
			flashtimer = 0.05
			get_node( "rotate/Sprite" ).get_material().set_shader_param( "on", 0.0 )
		else:
			#print( flashtimer )
			flashtimer -= delta
			if flashtimer <= 0:
				flashtimer = 0.05
				var curparam = get_node( "rotate/Sprite" ).get_material().get_shader_param( "on" )
				if curparam > 0.5:
					get_node( "rotate/Sprite" ).get_material().set_shader_param( "on", 0.0 )
				else:
					get_node( "rotate/Sprite" ).get_material().set_shader_param( "on", 1.0 )
	

var wander_state = 0
var wander_timer = 0
var vision_timer = 0
func _state_wander( delta ):
	# check for player
	vision_timer -= delta
	var psight = _player_on_sight()
	var pvision = _player_on_vision()
	if psight and pvision:
		state_nxt = STATES.CHASE
		wander_state = 0
		return
	elif psight and not pvision:
		if vision_timer > 0:
			state_nxt = STATES.CHASE
			wander_state = 0
			return
		else:
			vision_timer = -1
	if wander_state == 0:
		# move left or right until an obstacle is reached
		vel.x = lerp( vel.x, dir * MAX_VEL, 10 * delta )
		
		anim_nxt = "run"
		
		# check direction
		if _end_of_ground():
			# change direction
			dir = -dir
			# idle state
			wander_state = 1
			wander_timer = 3
			anim_nxt = "idle"
			vel = Vector2( 0, 0 )
	elif wander_state == 1:
		wander_timer -= delta
		if wander_timer <= 0:
			wander_state = 0
	vel.y += GRAVITY * delta
	vel = move_and_slide( vel, Vector2( 0, -1 ) )
	


var chace_state = 0
var chace_wait = 0

func _state_chace( delta ):
	if chace_state == 0:
		var dist = get_global_pos() - player.get_global_pos()
		if abs( sign( dist.x ) ) > 0:
			dir = -sign( dist.x )
		anim_repeat = true
		if dist.y <= abs( dist.x ):
			# horizontal fire
			anim_nxt = "fire_side"
		elif abs( dist.y ) > abs( dist.x ):
			# vertical fire
			anim_nxt = "fire_up"
		chace_wait = 0.3
		chace_state = 1
	elif chace_state == 1:
		chace_wait -= delta
		if chace_wait <= 0:
			# instantiate bulle
			#print( "pew pew" )
			var dist = get_global_pos() - player.get_global_pos()
			if abs( sign( dist.x ) ) > 0:
				dir = -sign( dist.x )
			var bullet_scn = preload( "res://scenes/bullet_1.tscn" )
			var bullet = bullet_scn.instance()
			bullet.dir = dist.normalized() * Vector2( -1, -1 )
			var relpos
			if dist.y <= abs( dist.x ):
				relpos = get_node( "rotate/bulletpos_1" ).get_pos() * Vector2( dir, 1 )
			elif abs( dist.y ) > abs( dist.x ):
				relpos = get_node( "rotate/bulletpos_2" ).get_pos() * Vector2( dir, 1 )
			bullet.set_global_pos( get_global_pos() + relpos )
			get_parent().add_child( bullet )
			samples.play( "laser" )
			# wait some more
			chace_wait = 0.5
			chace_state = 2
	elif chace_state == 2:
		chace_wait -= delta
		if chace_wait <= 0:
			# check again for the player
			if _player_on_sight():
				chace_state = 0
			else:
				#print( "player no longer in sight" )
				vision_timer = 10
				chace_state = 0
				state_nxt = STATES.WANDER
	# keep falling
	vel.y += GRAVITY * delta
	vel.x = lerp( vel.x, 0, 2 * delta )
	vel = move_and_slide( vel )
	pass
func _state_fire( delta ):
	pass

var is_dying = false
var is_dead = false
var hit_timer = 0
const HITVEL = 100
func die():
	if is_dying or is_dead: return
	is_dying = true
	hit_timer = 0.5
	var dir = ( get_global_pos() - player.get_global_pos() ).normalized()
	vel += dir * HITVEL
	global.camera.shake( 0.7, 10, 3 )	
	energy -= 1
	if energy < 0:
		is_dead = true
		set_fixed_process( false )
		anim.play( "die" )
		samples.play( "alien_explosion" )
		global.score += 1000
		yield( anim, "finished" )
		queue_free()
	else:
		global.score += 200
		samples.play( "alien_hit" )
	state_nxt = STATES.CHASE
	wander_state = 0
	
	
	pass
