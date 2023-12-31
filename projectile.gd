extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Explosion.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("aliens"):
		$Explosion.show()
		$Explosion.play()
		await $Explosion.animation_finished
		queue_free()
