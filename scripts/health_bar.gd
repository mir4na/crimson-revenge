extends ProgressBar
@onready var timer = $Timer
@onready var damage_bar = $DamageBar
var health = 0 : set = set_health

func set_health(new_health) -> void:
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

	if health <= 0:
		queue_free()
	
func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	damage_bar.value = health
