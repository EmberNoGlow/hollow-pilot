extends CharacterBody2D

const GRAVITY = 1400
@export var speed = 80
@export var max_health = 3
@export var damage = 1
@export var attack_range = 24
@export var attack_cooldown = 1.0

var health = 0
var target = null
var can_attack = true

func _ready():
	health = max_health
	if has_node("Detection"):
		$Detection.body_entered.connect(_on_Detection_body_entered)
		$Detection.body_exited.connect(_on_Detection_body_exited)
	if has_node("AttackTimer"):
		$AttackTimer.timeout.connect(_on_AttackTimer_timeout)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if target and is_instance_valid(target):
		var dir = (target.global_position - global_position)
		var dist = dir.length()
		if dist > attack_range:
			var move_dir = dir.normalized()
			velocity.x = lerp(velocity.x, move_dir.x * speed, 8.0 * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, 8.0 * delta)
			if can_attack:
				attack()
	else:
		velocity.x = lerp(velocity.x, 0.0, 8.0 * delta)
	move_and_slide()

func _on_Detection_body_entered(body):
	if body and body.name == "Player":
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
	var p = get_tree().get_root().get_node("Player")
	if p and p.has_method("add_souls"):
		p.add_souls(1)
	if health <= 0:
		die()

func die():
	var p = get_tree().get_root().get_node("Player")
	if p and p.has_method("add_souls"):
		p.add_souls(2)
	queue_free()
