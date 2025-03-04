extends Node

# Referências
onready var gridmap = get_parent().get_node("GridMap")  # Referência ao GridMap onde as paredes removíveis estão
onready var explosion_scene = preload("res://scenes/explosao.tscn")  # Cena de explosão
onready var timer = $Timer  # Timer para disparar as explosões

# Raio da explosão
const EXPLOSION_RADIUS = 2.0  # Raio de destruição da explosão
const EXPLOSION_INTERVAL = 2.0  # Intervalo de 2 segundos entre explosões
const GAME_START_TIME = 30.0  # 2 minutos de tempo de jogo (em segundos)

var game_time = 0.0  # Contador de tempo do jogo

# Função chamada a cada frame
func _process(delta):
	game_time += delta
	
	# Após 2 minutos, começa a disparar explosões aleatórias a cada 2 segundos
	if game_time >= GAME_START_TIME:
		if !timer.is_stopped():
			return
		timer.start(EXPLOSION_INTERVAL)  # Inicia o timer para disparar explosões

# Função chamada quando o Timer dispara
func _on_Timer_timeout():
	_create_random_explosion()  # Cria uma explosão aleatória no cenário

# Função para criar uma explosão aleatória
func _create_random_explosion():
	# Pega uma posição aleatória dentro do GridMap
	var random_x = randi() % gridmap.get_size().x
	var random_y = randi() % gridmap.get_size().y
	var random_pos = gridmap.map_to_world(Vector3(random_x, random_y, 0))

	# Cria uma instância da explosão
	var explosion = explosion_scene.instance()
	get_parent().add_child(explosion)  # Adiciona a explosão à cena
	explosion.global_transform.origin = random_pos  # Coloca a explosão na posição aleatória

	# Lida com a destruição dos blocos e interação com os jogadores
	_handle_explosion(explosion)

# Função para lidar com a explosão (destruir blocos e afetar jogadores)
func _handle_explosion(explosion):
	var bomb_pos = explosion.global_transform.origin
	var radius = int(EXPLOSION_RADIUS)

	# Afeta blocos do GridMap dentro do raio da explosão
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			for z in range(-radius, radius + 1):
				var offset = Vector3(x, y, z)
				if offset.length() <= EXPLOSION_RADIUS:
					var cell = gridmap.world_to_map(bomb_pos + offset)
					gridmap.set_cell_item(cell.x, cell.y, cell.z, -1)  # Remove o bloco

	# Afeta jogadores próximos à explosão
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		var distance = p.global_transform.origin.distance_to(bomb_pos)
		if distance <= EXPLOSION_RADIUS:
			if p.has_method("exploded"):
				p.exploded()  # Destrói o jogador

	# Remove a explosão após ela ter feito os efeitos
	explosion.queue_free()
