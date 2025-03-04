extends Spatial

# Variáveis
var in_area = []
var from_player
var has_exploded = false

var animplayer : AnimationPlayer = null
var animSpeed : float = 1.0

# Raio de destruição
const EXPLOSION_RADIUS = 2.0

# Referência ao GridMap
onready var gridmap = get_parent().get_node("GridMap") # Atualize o caminho conforme necessário

var explosao_scene = preload("res://scenes/explosao.tscn") # Precarrega a cena da explosao

# Quando a bomba entra em cena
func _ready():
	add_to_group("bombs")  # Adiciona a bomba ao grupo
	animplayer = get_node("AnimationPlayer")
	animplayer.play("flash") # Animação de piscar

# Processamento de cada frame
func _physics_process(delta): 
	animSpeed += 1.6 * delta
	animplayer.set_speed_scale(animSpeed)

	# Se a animação terminou, explode a bomba
	if animSpeed >= 5:
		explode()

# Detecta corpos na área
func _on_Area_body_entered(body):
	if not body in in_area:
		in_area.append(body)

# Remove corpos que saem da área
func _on_Area_body_exited(body):
	in_area.erase(body)

# Explosão
func explode():
	if has_exploded:
		return
	has_exploded = true  # Marca que essa bomba já explodiu
	
	# Criar efeito de explosão
	var explosao = explosao_scene.instance() # Cria uma instância da explosao
	get_parent().add_child(explosao) # Adiciona explosao na cena
	explosao.global_transform.origin = global_transform.origin # Garante que vai iniciar no mesmo local da bomba

	print("BOOM!")

	# Ativar outras bombas dentro do raio de explosão
	for bomb in get_tree().get_nodes_in_group("bombs"):
		if bomb != self and bomb.global_transform.origin.distance_to(global_transform.origin) <= EXPLOSION_RADIUS:
			bomb.explode()  # Aciona a explosão da outra bomba
	
	# Destruir objetos no raio de explosão
	for p in in_area:
		if p.is_in_group("player"):
			if p.has_method("exploded"):
				p.exploded()
  
	# Destruir blocos do GridMap dentro do raio de explosão
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
