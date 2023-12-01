extends Area2D

signal hit

@export var projectile_scene: PackedScene

@export var speed = 400
@export var projectile_speed = 400

var screen_size
var can_shoot = true


# Called when the node enters the scene tree for the first time.
func _ready():
	$DeathAnimation.hide()
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_gun_shooting()
	process_gun_movement()
	position += process_movement()  * delta
	if abs(position.x) > screen_size.x:
		position.x = screen_size.x
	if position.x < 0:
		position.x = 0
	
func start(pos):
	position = pos
	show()
	$CollisionPolygon2D.disabled = false
	
func process_gun_movement():
	if Input.is_action_pressed("gun_down"):
		$Gun.rotation += PI / 180
		$Gun/Path2D.rotation += PI / 180
	if Input.is_action_pressed("gun_up"):
		$Gun.rotation -= PI / 180
		$Gun/Path2D.rotation -= PI / 180
	
	if $Gun.rotation < -PI * 0.9:
		$Gun.rotation = -PI * 0.9
		$Gun/Path2D.rotation = -PI * 0.9
		
	if $Gun.rotation > PI / 10:
		$Gun.rotation = PI / 10
		$Gun/Path2D.rotation = PI / 10

func process_movement():
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$Tracks.play()
		$Tracks.flip_h = velocity.x < 0
		$Tower.flip_h = velocity.x < 0
	else: 
		$Tracks.stop()
	
	return velocity
	
func process_gun_shooting():
	if !can_shoot:
		return
		
	if Input.is_action_pressed("shoot"):
		shoot()
		can_shoot = false

func _on_rate_of_fire_timer_timeout():
	can_shoot = true
	
func shoot():
	var projectile = projectile_scene.instantiate()
	
	projectile.rotation = $Gun/Path2D.rotation - PI / 10
	projectile.position = $Gun.position + $Gun.get_rect().end.rotated(projectile.rotation)
	projectile.linear_velocity = Vector2(projectile_speed, 0.0).rotated(projectile.rotation)
	
	add_child(projectile)


func _on_body_entered(body):
	if !body.is_in_group("projectile"):
		being_hit()
		
func being_hit():
	$Tracks.hide()
	$Gun.hide()
	$Tower.hide()
	
	$DeathAnimation.show()
	$DeathAnimation.play()
	await $DeathAnimation.animation_finished
	hit.emit()
	
	hide()
	$Tracks.show()
	$Gun.show()
	$Tower.show()
