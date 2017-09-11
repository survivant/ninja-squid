extends KinematicBody2D

onready var anim = get_node( "rotate/anim" )
var anim_cur = ""
var anim_nxt = "idle"
var restart_anim = false

onready var samples = get_node( "samples" )

onready var rotate = get_node( "rotate" )
var direction_cur = 1
var direction_nxt = 1

enum STATES { GROUND, AIR }
var state_cur
var state_nxt = STATES.GROUND

const GRAVITY = 100
const MAX_GROUND_VEL = 100
const MAX_AIR_VEL = 150
const JUMP_VEL = 100
const JUMP_MARGIN = 0.25
const AIR_JUMP_VEL = 80
const GROUND_ACCEL = 5
const GROUND_DECCEL = 50
const AIR_ACCEL = 5
const AIR_DECCEL = 20
var vel = Vector2()
var _fall_time = 0



var input_states = preload( "res://scripts/input_states.gd" )
var btn_left = input_states.new( "btn_left" )
var btn_right = input_states.new( "btn_right" )
var btn_up = input_states.new( "btn_up" )
var btn_down = input_states.new( "btn_down" )
var btn_fire = input_states.new( "btn_fire" )

onready var raycasts = [ get_node( "rotate/ray_1" ), get_node( "rotate/ray_2" ) ]
var _is_jump = false

func _ready():
	global.player = self
	raycasts[0].add_exception( self )
	raycasts[1].add_exception( self )
	global.connect( "start_level", self, "_start" )
	#yield( global, "start_level" )
	#set_fixed_process( true )
	pass

func _start():
	set_fixed_process( true )


func _on_ground():
	return raycasts[0].is_colliding() or raycasts[1].is_colliding()
	pass


var flashtimer = 0.05
signal player_dead
func _fixed_process( delta ):
	
	if is_in_death:
		vel.y += 500 * delta
		set_pos( get_pos() + vel * delta )
		if vel.y > 500:
			queue_free()
			emit_signal( "player_dead" )
			global.camera.follow_player = true
		return
	#print( get_pos() )
	#print( state_nxt, " ", _on_ground() )
	state_cur = state_nxt
	if state_cur == STATES.GROUND:
		_state_ground( delta )
	elif state_cur == STATES.AIR:
		_state_air( delta )
	
	if direction_nxt != direction_cur:
		direction_cur = direction_nxt
		rotate.set_scale( Vector2( direction_cur, 1 ) )
	
	if anim_nxt != anim_cur or restart_anim:
		anim_cur = anim_nxt
		#print( anim_nxt, "   restarting: ", restart_anim )
		anim.play( anim_cur )#, -1, 1.5 )
		restart_anim = false
		
		if anim_cur != "fire":
			swordhit.set_layer_mask_bit( 1, false )
			swordhit.set_collision_mask_bit( 1, false )
	
	if _is_hit:
		#print( "hit counter" )
		hit_timer -= delta
		if hit_timer <= 0:
			_is_hit = false
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
	
var anim_prv = ""
func _state_ground( delta ):
	var user_input = true
	user_input = _end_fire( delta )
	
	# player input
	if user_input:
		if btn_left.check() == 2:
			vel.x = lerp( vel.x, -MAX_GROUND_VEL, delta * GROUND_ACCEL )
			if vel.x < 0:
				direction_nxt = -1
			anim_nxt = "run"
		elif btn_right.check() == 2:
			vel.x = lerp( vel.x, MAX_GROUND_VEL, delta * GROUND_ACCEL )
			if vel.x > 0:
				direction_nxt = 1
			anim_nxt = "run"
		else:
			if abs( vel.x ) > 1:
				vel.x = lerp( vel.x, 0, delta * GROUND_DECCEL )
			else:
				vel.x = 0
				anim_nxt = "idle"
		if btn_up.check() == 1:
			# jump
			_is_jump = true
			vel.y -= JUMP_VEL
			samples.play( "player_jump" )
	else:
		vel.x = lerp( vel.x, 0, delta * GROUND_DECCEL )
	if btn_fire.check() == 1:
		_fire( delta )
	
	vel.y += GRAVITY * delta
	if abs( vel.y ) > MAX_AIR_VEL: vel.y = sign( vel.y ) * MAX_AIR_VEL
	#vel = move_and_slide( vel, Vector2( 0, -1 ) )
	vel = move_and_slide( vel )
	if not _on_ground():
		#print( "leaving state ground for air" )
		state_nxt = STATES.AIR
		_fall_time = 0
	pass






func _state_air( delta ):
	var user_input = true
	if anim_cur == "fire" and anim.is_playing():
		user_input = false
	elif anim_cur == "fire":
		anim_nxt = anim_prv
	# player input
	if user_input:
		if btn_left.check() == 2:
			vel.x = lerp( vel.x, -MAX_AIR_VEL, delta * AIR_ACCEL )
			if vel.x < 0:
				direction_nxt = -1
		elif btn_right.check() == 2:
			vel.x = lerp( vel.x, MAX_AIR_VEL, delta * AIR_ACCEL )
			if vel.x > 0:
				direction_nxt = 1
		else:
			if abs( vel.x ) > 1:
				vel.x = lerp( vel.x, 0, delta * AIR_DECCEL )
			else:
				vel.x = 0
		
		if btn_up.check() == 1:
			if not _is_jump and _fall_time < JUMP_MARGIN:
				_is_jump = true
				vel.y -= JUMP_VEL
			else:
				vel.y -= AIR_JUMP_VEL
			anim_nxt = "jump up"
			restart_anim = true
			samples.play( "player_jump" )
		elif btn_down.check() == 2:
			vel.y = lerp( vel.y, MAX_AIR_VEL, delta * AIR_ACCEL )
		if vel.y > 0:
			anim_nxt = "idle"
			_fall_time += delta
	
	if btn_fire.check() == 1:
		_fire( delta )
	
	
	
	vel.y += GRAVITY * delta
	if abs( vel.y ) > MAX_AIR_VEL: vel.y = sign( vel.y ) * MAX_AIR_VEL
	vel = move_and_slide( vel )
	
	if _on_ground():
		#print( "leaving state air for ground" )
		state_nxt = STATES.GROUND
		_fall_time = 0
		_is_jump = false
	pass


onready var swordhit = get_node( "rotate/swordhit" )
func _fire( delta ):
	anim_nxt = "fire"
	anim_prv = anim_cur
	restart_anim = true
	var enemies = get_tree().get_nodes_in_group( "enemy_hitbox" )
	for enemy in enemies:
		if swordhit.overlaps_area( enemy ):
			enemy.get_parent().die()
	swordhit.set_layer_mask_bit( 1, true )
	swordhit.set_collision_mask_bit( 1, true )
	samples.play( "player_slash" )
func _end_fire( delta ):
	if anim_cur == "fire" and anim.is_playing():
		return false
	elif anim_cur == "fire":
		anim_nxt = anim_prv
		swordhit.set_layer_mask_bit( 1, false )
		swordhit.set_collision_mask_bit( 1, false )
	return true

const HITVEL = 1000
var hit_timer = 0
var _is_hit = false
func hit( dir ):
	if _is_hit: return
	_is_hit = true
	vel += dir * HITVEL
	hit_timer = 1
	global.energy -= 40
	global.camera.shake( 0.7, 20, 5 )
	samples.play( "player_hit" )
	

var is_in_death = false
func death():
	if is_in_death: return
	is_in_death = true
	print( "playing dead player" )
	samples.play( "player_dead" )
	vel = Vector2( 0, -200 )
	global.camera.follow_player = false
	


