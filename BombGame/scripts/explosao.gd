extends Node

var animplayer : AnimationPlayer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	animplayer = get_node("AnimationPlayer")
	animplayer.play("explosao") # Animação de piscar
	
	yield(animplayer, "animation_finished")
	queue_free()
