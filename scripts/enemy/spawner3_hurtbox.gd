class_name Spawner3HurtBox extends Area2D

func _init() -> void:
	collision_layer = 0
	collision_mask = 1

func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(hitbox: PlayerHitBox) -> void:
	if hitbox == null:
		return
		
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
