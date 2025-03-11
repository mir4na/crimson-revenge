extends Sprite2D

@onready var healthbar = $HealthBar
@onready var dead = $AnimatedSprite2D
@onready var timer = $Timer

var player: Node2D = null
var max_health = 100
var current_health: float
var enemy = load("res://scenes/enemy.tscn")

func _ready() -> void:
	add_to_group("spawners")
	
	current_health = max_health
	healthbar.init_health(current_health)
	dead.visible = false
	dead.connect("animation_finished", _on_dead_animation_finished)

	player = get_parent().get_node("Player")
	if player:
		player.connect("tree_exited", _on_player_died)

func _process(delta: float) -> void:
	if !is_instance_valid(player):
		if timer and timer.is_stopped() == false:
			timer.stop()

func _on_timer_timeout() -> void:
	if is_instance_valid(player):
		var spawn = enemy.instantiate()
		
		spawn.position = self.position + Vector2(0, 130)
		
		var main_scene = get_parent()
		main_scene.add_child(spawn)
		
		print("spawned at", spawn.position)
	else:
		timer.stop()
		print("Stopped spawning - player is dead")

func _on_player_died() -> void:
	print("Player died, stopping enemy spawner")
	if timer:
		timer.stop()
	player = null

func take_damage(amount):
	current_health -= amount
	update_health_bar()
	print("Spawner took damage: ", amount)
	if current_health <= 0:
		die()

func die():
	texture = null
	dead.visible = true
	healthbar.visible = false
	set_physics_process(false)
	set_process(false)
	dead.play("broken")
	
func _on_dead_animation_finished():
	queue_free()

func update_health_bar():
	if is_instance_valid(healthbar) and healthbar != null:
		healthbar.health = current_health
