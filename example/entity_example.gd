class_name EntityExample extends Node2D

var timer: Timer

func _init(spawn_position: Vector2, ttl: float):
	timer = Timer.new()
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(_kill)
	timer.wait_time = ttl
	global_position = spawn_position
	
func _ready():
	var sprite = Sprite2D.new()
	var texture = PlaceholderTexture2D.new()
	texture.size = Vector2(50, 50)
	sprite.texture = texture
	add_child(sprite)
	add_child(timer)
	timer.start()

func _kill():
	Console.print("Bye from %s" % name)
	var target_modulate = modulate
	target_modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate", target_modulate, 0.5)
	tween.finished.connect(func(): queue_free())
