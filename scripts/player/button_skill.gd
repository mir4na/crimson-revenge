extends TextureButton
class_name SkillButton

@onready var progress_bar = $ProgressBar
@onready var timer = $Timer
@onready var time = $Time
@onready var key = $Hotkey

var change_key = "":
	set(value):
		change_key = value
		key.text = value

func _ready():
	progress_bar.max_value = timer.wait_time
	set_process(false)
	
func _process(delta):
	time.text = "%3.1f" % timer.time_left
	progress_bar.value = timer.time_left
	
func _on_timer_timeout() -> void:
	disabled = false
	time.text = ""
	set_process(false)
	
func _on_pressed() -> void:
	timer.start()
	disabled = true
	set_process(true)
