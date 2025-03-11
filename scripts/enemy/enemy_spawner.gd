extends Node

var enemy = load("res://scenes/enemy.tscn")

@onready var spawn_point := $Sprite2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	var spawn = enemy.instantiate()
	
	spawn.position = spawn_point.position + Vector2(0, 100)
	
	var main_scene = get_parent()
	main_scene.add_child(spawn)
	
	print("spawned at", spawn.position)
