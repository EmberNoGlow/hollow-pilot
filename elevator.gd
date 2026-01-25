extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_instance_valid($"../Boss"):
		var p1 = Vector2(51,4)
		var p2 = Vector2(51,5)
		var p3 = Vector2(51,6)
		var p4 = Vector2(51,7)
		for p in [p1,p2,p3,p4]:
			$"../Ruins".erase_cell(p)
			print(p)


func _on_body_entered(body):
	if body is not CharacterBody2D:
		return
	var p1 = Vector2(36,8)
	var p2 = Vector2(37,8)
	var p3 = Vector2(38,8)
	for p in [p1,p2,p3]:
		$"../Ruins".erase_cell(p)
		print(p)
	start_tween()

var duration = 7.0
func start_tween():
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_parallel(false)
	tween.tween_property($"../Platform", "position", Vector2(909.359,-334.406), duration / 2)
	await get_tree().create_timer(5.0).timeout
	tween.tween_property($"../Platform", "position", Vector2(909.359,312.311), duration / 2)
