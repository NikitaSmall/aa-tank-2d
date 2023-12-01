extends Node

var score

@export var alien_bomb_scene: PackedScene
@export var alien_ship_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$Player.show()
	$AlienBombTimer.start()
	$AlienShipTimer.start()
	
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	
func game_over():
	score = 0
	$HUD.show_game_over()
	$AlienBombTimer.stop()
	$AlienShipTimer.stop()
	
	get_tree().call_group("aliens", "queue_free")


func _on_alien_bomb_timer_timeout():
	var alien_bomb = alien_bomb_scene.instantiate()
	alien_bomb.enemy_killed.connect(_on_enemy_killed)
	
	var alien_bomb_spawn_location = get_node("AlienBombSpawnPath/PathFollow2D")
	alien_bomb_spawn_location.progress_ratio = randf()
	
	alien_bomb.position = alien_bomb_spawn_location.position
	
	var direction = PI / 2
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0).rotated(direction)
	alien_bomb.linear_velocity = velocity

	# Spawn the mob by adding it to the Main scene.
	add_child(alien_bomb)


func _on_alien_ship_timer_timeout():
	var side = randi_range(1, 2)
	
	var alien_ship = alien_ship_scene.instantiate()
	alien_ship.enemy_killed.connect(_on_enemy_killed)
	var alien_ship_spawn_location = get_node("AlienShipSpawnPath" + str(side) + "/PathFollow2D")
	alien_ship_spawn_location.progress_ratio = randf()
	
	alien_ship.position = alien_ship_spawn_location.position

	var direction = 0.0
	if side == 2:
		alien_ship.set_collision_layer_value(3, true)
		alien_ship.set_collision_mask_value(3, true)
		direction = PI
	else:
		alien_ship.set_collision_layer_value(4, true)
		alien_ship.set_collision_mask_value(4, true)
		
	var velocity = Vector2(randf_range(250.0, 350.0), 0.0).rotated(direction)
	alien_ship.linear_velocity = velocity
	
	
	add_child(alien_ship)
	
func _on_enemy_killed():
	score += 1
	$HUD.update_score(score)


func _on_hud_start_game():
	new_game()


func _on_player_hit():
	game_over()
