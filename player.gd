extends CharacterBody2D

const GRAVITY = 1400
@export var speed = 200
@export var jump_speed = 450
@export var dash_speed = 700
@export var dash_time = 0.12
@export var max_health = 5
@export var max_souls = 6
@export var heal_cost = 1
@export var heal_amount = 1
@export var heal_delay = 0.8
@export var attack_cooldown = 0.4
@export var attack_damage = 1

var can_double_jump = true
var can_damage = true
var can_damage_timer = 0.0
var dashing = false
var dash_timer = 0.0

var souls = 0
var health = 0

var can_attack = true
var healing = false
var heal_timer = 0.0

var current_direction

@onready var health_bar: ProgressBar = $CanvasLayer/Control/Health
@onready var soul_bar: ProgressBar = $CanvasLayer/Control/Soul
@onready var attack_particles: GPUParticles2D = $AttackParticles
@onready var animation_player: AnimationPlayer = $CanvasLayer/Control/AnimationPlayer


func _ready():
	health_bar.max_value = max_health
	soul_bar.max_value = max_souls
	health = max_health
	souls = clamp(souls, 0, max_souls)
	# connect timer signal if present
	if has_node("AttackTimer"):
		$AttackTimer.timeout.connect(_on_AttackTimer_timeout)

func _physics_process(delta):
	if healing:
		heal_timer += delta
		if heal_timer >= heal_delay:
			if souls >= heal_cost:
				health = min(health + heal_amount, max_health)
				souls -= heal_cost
			healing = false
			heal_timer = 0.0
		return
		
	if not can_damage:
		can_damage_timer += delta
		if can_damage_timer >= 1.2:
			can_damage = true
			can_damage_timer = 0.0
	
		$Copilot.modulate = Color(1.0,0.0,0.0,1.0)
	else:
		$Copilot.modulate = Color(1.0,1.0,1.0,1.0)
	
	health_bar.value = lerp(health_bar.value, float(health), delta*10.0)
	soul_bar.value = lerp(soul_bar.value, float(souls), delta*10.0)

	if not dashing:
		var input_dir = Input.get_action_strength("right") - Input.get_action_strength("left")
		velocity.x = input_dir * speed

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		can_double_jump = true

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -jump_speed
		elif can_double_jump:
			velocity.y = -jump_speed
			can_double_jump = false

	if Input.is_action_just_pressed("dash") and not dashing:
		dashing = true
		dash_timer = dash_time
		var dir = sign(Input.get_action_strength("right") - Input.get_action_strength("left"))
		if dir == 0:
			dir = 1
		velocity.x = dir * dash_speed

	if dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			dashing = false
	
	current_direction = sign(velocity.x)
	var dir_sign = current_direction
	if dir_sign != 0:
		current_direction = dir_sign
		if has_node("AttackArea"):
			$AttackArea.position.x = -abs($AttackArea.position.x) if current_direction < 0 else abs($AttackArea.position.x)
		if attack_particles:
			attack_particles.process_material.gravity.x = -abs(attack_particles.process_material.gravity.x) if current_direction < 0 else abs(attack_particles.process_material.gravity.x)

	move_and_slide()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			attack()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				start_heal()
			else:
				cancel_heal()

func attack():
	if not can_attack or healing: return
	can_attack = false
	attack_particles.emitting = true
	if has_node("AttackTimer"):
		$AttackTimer.start(attack_cooldown)
	if has_node("AttackArea"):
		for body in $AttackArea.get_overlapping_bodies():
			if body == self:
				continue
			if body.has_method("take_damage"):
				body.take_damage(attack_damage)
				souls += 1
				souls = clamp(souls, 0, max_souls)

func _on_AttackTimer_timeout():
	can_attack = true
	if attack_particles:
		attack_particles.emitting = false

func start_heal():
	if souls < heal_cost: return
	healing = true
	heal_timer = 0.0

func cancel_heal():
	healing = false
	heal_timer = 0.0

func add_souls(amount):
	souls += amount

func take_damage(amount):
	if can_damage:
		health -= amount
		can_damage = false
	if health <= 0:
		die()

func die():
	animation_player.play("End")
	await get_tree().create_timer(1.125).timeout
	get_tree().reload_current_scene()


func TheEnd():
	animation_player.play("TheEnd")
