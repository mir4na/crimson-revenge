extends Sprite2D

@onready var healthbar = $HealthBar
@onready var dead = $AnimatedSprite2D
@onready var attack_right_left = $Attack
@onready var attack_down = $AttackDown
@onready var attack_up = $AttackUp
@onready var goblin_sound = $GoblinSound

@export var speed := 200
@export var max_health := 50
@export var sound_interval := 15.0

var current_health: float
var player: Node2D = null
var direction: Vector2
var is_attacking: bool = false
var previous_position = Vector2.ZERO
var sound_timer: Timer

func _ready():
	add_to_group("goblins")
	disable_all_hitboxes()
	
	dead.visible = false
	player = get_parent().get_node("Player")
	current_health = max_health
	healthbar.init_health(current_health)
	dead.connect("animation_finished", _on_dead_animation_finished)
	previous_position = position

	if goblin_sound is AudioStreamPlayer2D:
		goblin_sound.play()
		
	sound_timer = Timer.new()
	sound_timer.wait_time = sound_interval
	sound_timer.one_shot = false
	sound_timer.autostart = true
	sound_timer.connect("timeout", _on_sound_timer_timeout)
	add_child(sound_timer)

func disable_all_hitboxes():
	attack_right_left.monitoring = false
	attack_right_left.monitorable = false
	
	attack_down.monitoring = false
	attack_down.monitorable = false 
	
	attack_up.monitoring = false
	attack_up.monitorable = false

func _process(delta):
	if player and is_instance_valid(player):
		update_z_index()
		if not is_attacking:
			move_or_attack(delta)
	else:
		$AnimationPlayer.play("idle")

func move_or_attack(delta):
	direction = (player.global_position - global_position).normalized()
	if position.distance_to(player.global_position) <= 60:
		if not is_attacking:
			attack()
	else:
		$AnimationPlayer.play("walk")
		
		previous_position = position

		var potential_move = direction * speed * delta
		var can_move_x = true
		var can_move_y = true

		if direction.x != 0:
			var test_position_x = Vector2(position.x + potential_move.x, position.y)
			if check_point_collision(test_position_x):
				can_move_x = false

		if direction.y != 0:
			var test_position_y = Vector2(position.x, position.y + potential_move.y)
			if check_point_collision(test_position_y):
				can_move_y = false

		if can_move_x:
			position.x += potential_move.x
		if can_move_y:
			position.y += potential_move.y

		if direction.x < 0:
			flip_h = true
		elif direction.x > 0:
			flip_h = false

func check_point_collision(test_position: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query_parameters = PhysicsShapeQueryParameters2D.new()

	var shape = CircleShape2D.new()
	shape.radius = 20.0 
	
	query_parameters.shape = shape
	query_parameters.transform = Transform2D(0, test_position)
	query_parameters.collision_mask = 1
	query_parameters.collide_with_bodies = true
	
	var result = space_state.intersect_shape(query_parameters)
	
	for collision in result:
		if collision.collider is StaticBody2D:
			return true
	
	return false

func attack():
	if position.y > player.position.y:
		attack_above()
	elif position.y <= player.position.y:
		attack_below()

func enable_hitbox(hitbox):
	hitbox.monitoring = true
	hitbox.monitorable = true
	hitbox.monitoring = false
	hitbox.monitorable = false

func attack_right():
	is_attacking = true
	
	$AnimationPlayer.play("attack")
	await $AnimationPlayer.animation_finished
	
	enable_hitbox(attack_right_left)
	
	$AnimationPlayer.play("idle")
	await get_tree().create_timer(2).timeout
	is_attacking = false
	
func attack_left():
	is_attacking = true
	
	$AnimationPlayer.play("attack")
	await $AnimationPlayer.animation_finished
	
	attack_right_left.position = Vector2(player.position.x, player.position.y)
	enable_hitbox(attack_right_left)
	
	$AnimationPlayer.play("idle")
	await get_tree().create_timer(2).timeout
	is_attacking = false

func attack_above():
	is_attacking = true
	
	$AnimationPlayer.play("attack_up")
	await $AnimationPlayer.animation_finished
	
	enable_hitbox(attack_up)
	
	print("player:", player.position.x)
	print("collision:", attack_right_left.position.x)
	print(attack_right_left.position.x - player.position.x)
	
	$AnimationPlayer.play("idle")
	await get_tree().create_timer(2).timeout
	is_attacking = false

func attack_below():
	is_attacking = true
	
	$AnimationPlayer.play("attack_down")
	await $AnimationPlayer.animation_finished
	
	enable_hitbox(attack_down)
	
	$AnimationPlayer.play("idle")
	await get_tree().create_timer(2).timeout
	is_attacking = false

func take_damage(amount):
	current_health -= amount
	print("Enemy took damage: ", amount)
	
	if is_instance_valid(healthbar) and healthbar != null:
		update_health_bar()
		
	if current_health <= 0:
		die()

func die():
	texture = null
	dead.visible = true
	if is_instance_valid(healthbar):
		healthbar.visible = false
	$AnimationPlayer.stop()
	set_physics_process(false)
	set_process(false)

	if sound_timer and is_instance_valid(sound_timer):
		sound_timer.disconnect("timeout", _on_sound_timer_timeout)
		sound_timer.stop()
		remove_child(sound_timer)
		sound_timer.queue_free()
		sound_timer = null
	
	dead.play("dead")
	
func _on_dead_animation_finished():
	queue_free()

func update_health_bar():
	if is_instance_valid(healthbar) and healthbar != null:
		healthbar.health = current_health

func update_z_index():
	if position.y > player.position.y:
		z_index = 2
	else:
		z_index = 0

func _on_sound_timer_timeout():
	if goblin_sound is AudioStreamPlayer2D:
		goblin_sound.play()
