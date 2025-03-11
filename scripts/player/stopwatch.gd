extends Label

var time_elapsed: float = 0
var running: bool = true

func _ready():
	text = "00:00:00"
	running = true
	size = Vector2(2,4)

func _process(delta):
	if running:
		time_elapsed += delta
		update_display()

func update_display():
	var minutes = int(time_elapsed / 60)
	var seconds = int(fmod(time_elapsed, 60))
	var milliseconds = int(fmod(time_elapsed, 1) * 100)

	text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

func start():
	running = true

func stop():
	running = false

func reset():
	time_elapsed = 0
	update_display()

func restart():
	reset()
	start()
