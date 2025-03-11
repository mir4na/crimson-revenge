extends Node2D

@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var player = $Player
@onready var spawn_point = $Marker
@onready var ui_label = $CanvasLayer/ObjectiveInfo
var paused = false
var victory_scene = preload("res://scenes/victory.tscn")
var defeat_scene = preload("res://scenes/defeat.tscn")
var victory_shown = false
var defeat_shown = false
var total_hoods = 0
var destroyed_hoods = 0

func _ready() -> void:
	pause_menu.hide()
	ui_label.position = Vector2(20, 100)
	ui_label.add_theme_font_size_override("font_size", 25)
	if player and spawn_point:
		player.position = spawn_point.position

	total_hoods = get_tree().get_nodes_in_group("spawners").size()
	update_ui_label()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		pauseMenu()
		get_viewport().set_input_as_handled()
		return
	if paused and not (event is InputEventMouseMotion or event is InputEventMouseButton and pause_menu.get_rect().has_point(event.position)):
		get_viewport().set_input_as_handled()

func pauseMenu():
	paused = !paused
	if paused:
		pause_menu.show()
		get_tree().paused = true
	else:
		pause_menu.hide()
		get_tree().paused = false

func _process(delta: float) -> void:
	if not victory_shown:
		check_victory_condition()
	if not defeat_shown:
		check_lose_condition()
	
	var current_hoods = get_tree().get_nodes_in_group("spawners").size()
	if current_hoods < total_hoods - destroyed_hoods:
		destroyed_hoods = total_hoods - current_hoods
		update_ui_label()

func update_ui_label() -> void:
	ui_label.text = "Destroy All Goblin's Hoods: " + str(destroyed_hoods) + "/" + str(total_hoods) + "\nEliminate All Goblins!"

func check_victory_condition():
	var spawners = get_tree().get_nodes_in_group("spawners")
	var goblins = get_tree().get_nodes_in_group("goblins")
	if spawners.size() == 0 and goblins.size() == 0:
		show_victory()

func show_victory():
	victory_shown = true
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	
	var victory_instance = victory_scene.instantiate()
	canvas_layer.add_child(victory_instance)
	get_tree().paused = true

func check_lose_condition():
	var player_node = get_tree().get_nodes_in_group("players")
	if player_node.size() == 0 or not is_instance_valid(player):
		show_defeat()
		
func show_defeat():
	defeat_shown = true
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	var defeat_instance = defeat_scene.instantiate()
	canvas_layer.add_child(defeat_instance)
	get_tree().paused = true
