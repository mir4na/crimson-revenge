extends Node2D

var prologue_lines = [
	"The goblin village lay in ruins and dust,\nTheir screams had faded, their blades turned to rust.\nYet as he stood amidst the crimson ground,\nA hollow silence was all he found.",
	"His heart still burned, but something felt wrong,\nWere they truly the villains all along?\nTheir eyes held fear, not wicked delight,\nPerhaps they, too, were bound by might.",
	"He clenched his fists but steadied his breath,\nVengeance alone could not bring death to death.\nWith a mind now clear and purpose anew,\nHe raised his sword—there was more to do.",
	"To be continued...",
]

@onready var text_label: Label = $TextLabel
@onready var skip_notice_label : Label =  $SkipLabel

var current_line_index = 0
var reveal_timer: Timer
var hold_timer: Timer
var fadeout_timer: Timer
var current_visible_text = ""
var current_char_index = 0
var fulltext = ""
var skip_enabled = false

func _ready():
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	skip_notice_label.visible = false

	var control = Control.new()
	control.anchor_right = 1.0
	control.anchor_bottom = 1.0
	control.add_child(skip_notice_label)
	
	add_child(control)
	
	reveal_timer = Timer.new()
	reveal_timer.one_shot = false
	reveal_timer.wait_time = 0.0001
	reveal_timer.timeout.connect(_on_reveal_timer_timeout)
	add_child(reveal_timer)
	
	hold_timer = Timer.new()
	hold_timer.one_shot = true
	hold_timer.wait_time = 5.0
	hold_timer.timeout.connect(_on_hold_timer_timeout)
	add_child(hold_timer)
	
	fadeout_timer = Timer.new()
	fadeout_timer.one_shot = false
	fadeout_timer.wait_time = 0.0001
	fadeout_timer.timeout.connect(_on_fadeout_timer_timeout)
	add_child(fadeout_timer)
	
	print("Starting prologue text sequence")
	for i in range(prologue_lines.size()):
		print("Line ", i, " length: ", prologue_lines[i].length())

	var skip_timer = Timer.new()
	skip_timer.one_shot = true
	skip_timer.wait_time = 5.0
	skip_timer.timeout.connect(_on_skip_timer_timeout)
	add_child(skip_timer)
	skip_timer.start()
	
	print("Skip functionality will be enabled after 5 seconds")
	
	start_next_line()

func _process(delta: float) -> void:
	if skip_enabled and Input.is_action_just_pressed("skip_scene"):
		print("Scene skipped by user input")
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_skip_timer_timeout():
	skip_enabled = true
	print("Skip functionality is now enabled")
	skip_notice_label.visible = true

func start_next_line():
	if current_line_index >= prologue_lines.size():
		text_label.text = ""
		return
	
	print("Starting line: ", current_line_index)
	fulltext = prologue_lines[current_line_index]
	current_visible_text = ""
	current_char_index = 0
	text_label.text = ""
	reveal_timer.start()

func _on_reveal_timer_timeout():
	if current_char_index < fulltext.length():
		current_visible_text += fulltext[current_char_index]
		text_label.text = current_visible_text
		current_char_index += 1
		if current_char_index % 10 == 0:
			print("Displaying character: ", current_char_index, "/", fulltext.length())
	else:
		print("Full text displayed, holding for 5 seconds")
		reveal_timer.stop()
		hold_timer.start()

func _on_hold_timer_timeout():
	print("Hold complete, checking if last line")
	if current_line_index == prologue_lines.size() - 1:
		print("Last line reached - keeping text visible")
	else:
		print("Not the last line, starting fadeout")
		fadeout_timer.start()

func _on_fadeout_timer_timeout():
	if current_visible_text.length() > 0:
		current_visible_text = current_visible_text.substr(0, current_visible_text.length() - 1)
		text_label.text = current_visible_text
		if current_visible_text.length() % 10 == 0:
			print("Fading out: ", current_visible_text.length(), " characters remaining")
	else:
		print("Fadeout complete for line: ", current_line_index)
		fadeout_timer.stop()
		current_line_index += 1
		print("Waiting before next line...")
		await get_tree().create_timer(1.0).timeout
		start_next_line()
