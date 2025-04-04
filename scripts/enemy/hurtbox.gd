class_name EnemyHurtBox extends Area2D

func _init() -> void:
	collision_layer = 0
	collision_mask = 1

func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(hitbox) -> void:
	if hitbox == null:
		return
		
	if (hitbox is PlayerHitBox or hitbox is SlashHitBox or hitbox is LightningHitBox) and owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
