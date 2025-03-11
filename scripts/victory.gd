extends Control

@onready var main = get_node("/root/Story")

func _ready() -> void:
	$AnimationPlayer.play("blur")
	process_mode = Node.PROCESS_MODE_ALWAYS

	anchor_right = 1.0
	anchor_bottom = 1.0
	grow_horizontal = 2
	grow_vertical = 2
	
	
func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_continue_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/epilogue.tscn")
