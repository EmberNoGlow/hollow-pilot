extends CharacterBody2D

const GRAVITY = 1400
@export var max_health = 10
@export var speed = 100
@export var lunge_speed = 600
@export var lunge_duration = 0.35
@export var punch_damage = 2
@export var lunge_damage = 3
@export var ranged_damage = 1
@export var melee_range = 40
@export var lunge_range = 200
@export var ranged_range = 300
@export var attack_cooldown = 1.2

var health = 0
var target = null
var state = "idle"
var state_timer = 0.0
var can_attack = true

func _ready():
	health = max_health
	if has_node("Detection"):
		$Detection.body_entered.connect(_on_Detection_body_entered)
		$Detection.body_exited.connect(_on_Detection_body_exited)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if target and is_instance_valid(target):
		var to_player = target.global_position - global_position
		var dist = to_player.length()
		match state:
			"idle":
				velocity = Vector2.ZERO
				if can_attack:
					if dist > ranged_range:
						_do_ranged()
					elif dist > melee_range and dist <= lunge_range:
						_start_lunge(to_player)
					elif dist <= melee_range:
						_do_punch()
			"lunge":
				state_timer -= delta
				# keep moving during lunge (velocity already set)
				if state_timer <= 0:
					_end_lunge()
			"ranged","punch","cooldown":
				state_timer -= delta
				if state_timer <= 0:
					state = "idle"
					can_attack = true
	else:
		state = "idle"
	move_and_slide()

func _start_lunge(to_player):
	state = "lunge"
	can_attack = false
	state_timer = lunge_duration
	var dir = to_player.normalized()
	velocity = dir * lunge_speed

func _end_lunge():
	# stop lunge and do damage check
	if target and is_instance_valid(target):
		if global_position.distance_to(target.global_position) <= melee_range + 10:
			if target.has_method("take_damage"):
				target.take_damage(lunge_damage)
	velocity = Vector2.ZERO
	state = "cooldown"
	state_timer = attack_cooldown

func _do_punch():
	state = "punch"
	can_attack = false
	state_timer = 0.4
	if target and target.has_method("take_damage"):
		target.take_damage(punch_damage)

func _do_ranged():
	state = "ranged"
	can_attack = false
	state_timer = 0.6
	# simple instant ranged hit for now
	if target and target.has_method("take_damage"):
		target.take_damage(ranged_damage)

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
		p.add_souls(10)
	queue_free()


func _on_Detection_body_entered(body):
	if body and body.name == "Player":
		target = body

func _on_Detection_body_exited(body):
	if body == target:
		target = null
