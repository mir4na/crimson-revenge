extends Control

@onready var main = get_node("/root/Story")

func _ready() -> void:
	$AnimationPlayer.play("blur")
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _on_resume_pressed() -> void:
	main.pauseMenu()
	
func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
func _on_restart_pressed() -> void:
	get_tree().paused = false
	main.pauseMenu()
	get_tree().reload_current_scene()
