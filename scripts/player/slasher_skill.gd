class_name SlashHitBox extends Area2D

@export var damage := 40

func _init() -> void:
	collision_layer = 1
	collision_mask = 0
	connect("area_entered", _on_area_entered)

func _on_area_entered(area):
	monitoring = false
	monitorable = false
