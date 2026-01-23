extends CharacterBody2D

@export var speed = 80
@export var max_health = 3
@export var damage = 1
@export var attack_range = 24
@export var attack_cooldown = 1.0

var health = max_health
var target = null
var can_attack = true

func _ready():
	if has_node("Detection"):
		$Detection.body_entered.connect(_on_Detection_body_entered)
		$Detection.body_exited.connect(_on_Detection_body_exited)
	if has_node("AttackTimer"):
		$AttackTimer.timeout.connect(_on_AttackTimer_timeout)

func _physics_process(delta):
	if target and is_instance_valid(target):
		var dir = (target.global_position - global_position)
		var dist = dir.length()
		if dist > attack_range:
			dir = dir.normalized()
			velocity.x = dir.x * speed
		else:
			velocity.x = 0
			if can_attack:
				attack()
	else:
		velocity.x = 0
	move_and_slide()

func _on_Detection_body_entered(body):
	if body.name == "Player":
		target = body

func _on_Detection_body_exited(body):
	if body == target:
		target = null

func attack():
	can_attack = false
	if target and target.has_method("take_damage"):
		target.take_damage(damage)
	if has_node("AttackTimer"):
		$AttackTimer.start(attack_cooldown)

func _on_AttackTimer_timeout():
	can_attack = true

func take_damage(amount):
	health -= amount
	# give one soul to player when hit
	var p = get_tree().get_current_scene().get_node("Player") if get_tree().get_current_scene().has_node("Player") else null
	if p and p.has_method("add_souls"):
		p.add_souls(1)
	if health <= 0:
		die()

func die():
	var p = get_tree().get_current_scene().get_node("Player") if get_tree().get_current_scene().has_node("Player") else null
	if p and p.has_method("add_souls"):
		p.add_souls(2)
	queue_free()
