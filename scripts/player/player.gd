extends Sprite2D

var speed = 400
var cooldown_attack = 0.4
var max_health = 140
var is_attacking = false
var can_attacking = true
var can_use_slasher = true
var current_health: float

var cooldown_slasher = 10.0
var slasher_duration = 5.0

var cooldown_lightning = 25.0
var lightning_duration = 8.0

var previous_position = Vector2.ZERO
var collision_offset = 50.0

@onready var sword_sfx := $SwordEffect
@onready var healthbar := $HealthBar
@onready var attack_right_left := $Attack
@onready var attack_down := $AttackDown
@onready var attack_up := $AttackUp
@onready var dead := $AnimatedSprite2D

@onready var slash_skill := $SlasherSkill
@onready var slash_animation := $SlasherSkill/AnimatedSprite2D
@onready var slash_button := $ButtonSlash

@onready var thunder_sfx := $LightningEffect
@onready var lightning_skill := $LightningSkill
@onready var lightning_animation := $LightningSkill/AnimatedSprite2D
@onready var lightning_button := $ButtonLightning

func get_input(delta):
	if is_attacking:
		return
	
	previous_position = position
		
	var input_direction = Input.get_vector("left", "right", "up", "down")
	var movement = input_direction * delta * speed
	var can_move_x = true
	var can_move_y = true
	
	if input_direction.x != 0:
		var test_position_x = Vector2(position.x + movement.x, position.y)
		if check_point_collision(test_position_x):
			can_move_x = false
	
	if input_direction.y != 0:
		var test_position_y = Vector2(position.x, position.y + movement.y)
		if check_point_collision(test_position_y):
			can_move_y = false
	
	if can_move_x:
		position.x += movement.x
	if can_move_y:
		position.y += movement.y

	if input_direction.x < 0:
		flip_h = true
	elif input_direction.x > 0:
		flip_h = false
	
	if input_direction.length() > 0:
		$AnimationPlayer.play("walk")
	else:
		$AnimationPlayer.play("idle")

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

func _ready() -> void:
	add_to_group("players")
	
	$AnimationPlayer.play("idle")
	
	disable_all_hitboxes()
	
	dead.visible = false
	dead.connect("animation_finished", _on_dead_animation_finished)
	
	slash_animation.visible = false
	slash_button.timer.wait_time = cooldown_slasher
	slash_button.change_key = "X"
	
	lightning_animation.visible = false
	lightning_button.timer.wait_time = cooldown_lightning
	lightning_button.change_key = "C"
	
	current_health = max_health

	previous_position = position

func disable_all_hitboxes():
	attack_right_left.monitoring = false
	attack_right_left.monitorable = false
	
	attack_down.monitoring = false
	attack_down.monitorable = false
	
	attack_up.monitoring = false
	attack_up.monitorable = false
	
	slash_skill.monitoring = false
	slash_skill.monitorable = false
	
	lightning_skill.monitoring = false
	lightning_skill.monitorable = false
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack_right") and can_attacking:
		attack_right()
	elif Input.is_action_just_pressed("attack_left") and can_attacking:
		attack_left()
	elif Input.is_action_just_pressed("attack_above") and can_attacking:
		attack_above()
	elif Input.is_action_just_pressed("attack_below") and can_attacking:
		attack_below()
	elif Input.is_action_just_pressed("skill_1") and !slash_button.disabled:
		slash_button._on_pressed()
		slasher_dance()
	elif Input.is_action_just_pressed("skill_2") and !lightning_button.disabled:
		lightning_button._on_pressed()
		lightning_strike()
		
	get_input(delta)

func attack_right():
	can_attacking = false
	is_attacking = true
	flip_h = false
	$AnimationPlayer.play("attack_right_left")
	sword_sfx.play()
	await $AnimationPlayer.animation_finished
	
	attack_right_left.position = Vector2(75, 6)
	enable_hitbox(attack_right_left)
	is_attacking = false
	await get_tree().create_timer(cooldown_attack).timeout
	can_attacking = true
	
func attack_left():
	can_attacking = false
	is_attacking = true
	flip_h = true
	$AnimationPlayer.play("attack_right_left")
	sword_sfx.play()
	await $AnimationPlayer.animation_finished
	
	attack_right_left.position = Vector2(-75, 6)
	enable_hitbox(attack_right_left)
	is_attacking = false
	await get_tree().create_timer(cooldown_attack).timeout
	can_attacking = true

func attack_above():
	can_attacking = false
	is_attacking = true
	
	$AnimationPlayer.play("attack_up")
	sword_sfx.play()
	await $AnimationPlayer.animation_finished
	
	enable_hitbox(attack_up)
	
	is_attacking = false
	
	await get_tree().create_timer(cooldown_attack).timeout
	can_attacking = true

func attack_below():
	can_attacking = false
	is_attacking = true
	
	$AnimationPlayer.play("attack_down")
	sword_sfx.play()
	await $AnimationPlayer.animation_finished
	
	enable_hitbox(attack_down)
	
	is_attacking = false
	
	await get_tree().create_timer(cooldown_attack).timeout
	can_attacking = true
	
func slasher_dance():
	slash_skill.position = Vector2(0, 0)
	slash_animation.visible = true
	slash_skill.monitoring = true
	slash_skill.monitorable = true
	
	play_all_slash_animations()
	
	sword_sfx.play()
	await get_tree().create_timer(slasher_duration).timeout
	
	slash_skill.monitoring = false
	slash_skill.monitorable = false
	slash_animation.visible = false

func play_all_slash_animations():
	var anim_delay = slasher_duration / 3.0

	slash_animation.play("slash")
	await get_tree().create_timer(anim_delay).timeout
	slash_animation.play("double_slash")
	await get_tree().create_timer(anim_delay).timeout
	slash_animation.play("big_slash")
	
func lightning_strike():
	lightning_skill.position = Vector2(0, 0)
	lightning_skill.monitoring = true
	lightning_skill.monitorable = true

	create_lightning_storm()

	thunder_sfx.play() 

	await get_tree().create_timer(lightning_duration).timeout

	lightning_skill.monitoring = false
	lightning_skill.monitorable = false

func create_lightning_storm():
	var area_radius = 150.0
	var max_concurrent_strikes = 6
	var total_waves = 4
	var wave_delay = lightning_duration / total_waves
	
	for wave in range(total_waves):
		var lightning_nodes = []

		for i in range(max_concurrent_strikes):
			var new_lightning = lightning_animation.duplicate()
			add_child(new_lightning)

			var random_angle = randf() * 2 * PI
			var random_distance = randf_range(30.0, area_radius)
			var random_position = Vector2(cos(random_angle), sin(random_angle)) * random_distance

			new_lightning.position = random_position
			new_lightning.visible = true

			var animations = ["thunder_strike", "lightning"]
			var random_anim = animations[randi() % animations.size()]

			new_lightning.play(random_anim)

			lightning_nodes.append(new_lightning)

		await get_tree().create_timer(wave_delay).timeout

		for node in lightning_nodes:
			node.queue_free()

func enable_hitbox(hitbox):
	hitbox.monitoring = true
	hitbox.monitorable = true
	hitbox.monitoring = false
	hitbox.monitorable = false

func take_damage(amount):
	current_health -= amount
	update_health_bar()
	print("attacked")
	if current_health <= 0:
		die()
		
func die():
	texture = null
	dead.visible = true
	healthbar.visible = false
	$AnimationPlayer.stop()
	set_physics_process(false)
	set_process(false)
	dead.play("dead")

func _on_dead_animation_finished():
	queue_free()
	
func update_health_bar():
	healthbar.value = (current_health / float(max_health)) * 100
