extends Node2D

func _ready() -> void:
	get_tree().paused = false

func _process(delta: float) -> void:
	pass
	
func _on_start_pressed() -> void:
	print("Start button clicked")
	TransitionScreen.load_scene("res://scenes/prologue.tscn")

func _on_button_quit_pressed() -> void:
	get_tree().quit()
