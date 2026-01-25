extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$"../Area2D2".body_entered.connect(_on_mus_body_entered)
	$"../Area2D2".body_exited.connect(_on_mus_body_exited)


func _on_mus_body_entered(body):
	if body.name == "Player" and is_instance_valid($"../Boss"):
		if $"../Area2D2/AudioStreamPlayer".stream == preload("uid://dxpnxudvv4hpw"): return
		$"../Area2D2/AudioStreamPlayer".stream = preload("uid://dxpnxudvv4hpw")
		$"../Area2D2/AudioStreamPlayer".play()

func _on_mus_body_exited(body):
	if body.has_method("start_heal") and not is_instance_valid($"../Boss"):
		if $"../Area2D2/AudioStreamPlayer".stream == preload("uid://o0nqitgd48di"): return
		$"../Area2D2/AudioStreamPlayer".stream = preload("uid://o0nqitgd48di")
		$"../Area2D2/AudioStreamPlayer".play()



func _on_body_entered(body):
	if body is not CharacterBody2D:
		return
	body.TheEnd()
