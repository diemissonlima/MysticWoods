extends CharacterBody2D

var state_machine
var is_attacking: bool = false

@export_category("Variables")
@export var move_speed: float = 64.0
@export var friction: float = 0.2
@export var acceleration: float = 0.2

@export_category("Objects")
@export var attack_timer: Timer = null
@export var animation_tree: AnimationTree = null

func _ready() -> void:
	state_machine = animation_tree["parameters/playback"]


func _physics_process(_delta: float) -> void:
	move()
	attack()
	animate()
	move_and_slide()
	
	
func move() -> void:
	var direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	
	
	if direction != Vector2.ZERO:
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/walk/blend_position"] = direction
		animation_tree["parameters/attack/blend_position"] = direction
		
		velocity.x = lerp(velocity.x, direction.normalized().x * move_speed, acceleration)
		velocity.y = lerp(velocity.y, direction.normalized().y * move_speed, acceleration)
		return
	
	velocity.x = lerp(velocity.x, direction.normalized().x * move_speed, friction)
	velocity.y = lerp(velocity.y, direction.normalized().y * move_speed, friction)
	
	
	velocity = direction.normalized() * move_speed
	move_and_slide()
	
	
func attack() -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		set_physics_process(false)
		attack_timer.start()
		is_attacking = true
	

func animate() -> void:
	if is_attacking:
		state_machine.travel("attack")
		return
		
	if velocity.length() > 5:
		state_machine.travel("walk")
		return
	
	state_machine.travel("idle")


func _on_attack_timer_timeout() -> void:
	set_physics_process(true)
	is_attacking = false
