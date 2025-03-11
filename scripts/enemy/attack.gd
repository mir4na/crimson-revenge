class_name EnemyHitBox extends Area2D

@export var damage := 10

func _init() -> void:
	collision_layer = 2 
	collision_mask = 0
	connect("area_entered", _on_area_entered)

func _on_area_entered(area):
	monitoring = false
	monitorable = false
