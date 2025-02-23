extends Spatial

# Variáveis
var in_area = []
var from_player

var animplayer : AnimationPlayer = null
var animSpeed : float = 1.0

# Raio de destruição
const EXPLOSION_RADIUS = 3.0

# Referência ao GridMap
onready var gridmap = get_parent().get_node("GridMap") # Atualize o caminho conforme necessário

# Quando a bomba entra em cena
func _ready():
	animplayer = get_node("AnimationPlayer")
	animplayer.play("flash") # Animação de piscar

# Processamento de cada frame
func _physics_process(delta): 
	animSpeed += 0.6 * delta
	if animSpeed >= 5:
		print("BOOM!")
		explode()
		queue_free() # Remove a bomba
	animplayer.set_speed_scale(animSpeed)

# Detecta corpos na área
func _on_Area_body_entered(body):
	if not body in in_area:
		in_area.append(body)

# Remove corpos que saem da área
func _on_Area_body_exited(body):
	in_area.erase(body)

# Explosão
func explode():
	# Destruir objetos no raio de explosão
	for p in in_area:
		if p.is_in_group("player"):
			if p.has_method("exploded"):
				p.exploded()

	# Destruir blocos do GridMap em um raio de EXPLOSION_RADIUS
	var bomb_pos = global_transform.origin
	var radius = int(EXPLOSION_RADIUS)

	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			for z in range(-radius, radius + 1):
				var offset = Vector3(x, y, z)
				if offset.length() <= EXPLOSION_RADIUS:
					var cell = gridmap.world_to_map(bomb_pos + offset)
					gridmap.set_cell_item(cell.x, cell.y, cell.z, -1) # Remove o bloco

	queue_free() # Destroi a bomba
