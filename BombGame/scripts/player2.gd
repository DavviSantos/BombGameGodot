extends KinematicBody

var vetor = Vector3(0, 0, 0)
const velocidade = 6
const velocidade_rotacao = 5 # Suavidade da rotação

onready var mesh = $MeshInstance # Referência da mesh
onready var respawn_point = get_parent().get_node("Position3D") # Ponto de respawn
var bomba_escena = preload("res://scenes/bomb3d.tscn") # Precarrega a cena da bomba

func _ready():
	respawn() # Posiciona o jogador no ponto de respawn quando o jogo começa

func _physics_process(delta):
	vetor = Vector3.ZERO # Resetar vetor de movimento

	# Detecta movimento baseado na entrada
	if Input.is_action_pressed("move_right"):
		vetor.x += 1
	if Input.is_action_pressed("move_left"):
		vetor.x -= 1
	if Input.is_action_pressed("move_up"):
		vetor.z -= 1
	if Input.is_action_pressed("move_down"):
		vetor.z += 1

	# Se houver movimento, a mesh deve apontar na direção correta
	if vetor.length() > 0:
		vetor = vetor.normalized() * velocidade

		# Corrigido: Inverter os eixos no cálculo do ângulo
		var angulo = atan2(vetor.z, vetor.x) # Agora X é o eixo "para frente"

		# Rotaciona suavemente em direção ao movimento
		mesh.rotation.y = lerp_angle(mesh.rotation.y, -angulo + deg2rad(90), velocidade_rotacao * delta)

	move_and_slide(vetor)

	# Solta uma bomba ao apertar a tecla configurada
	if Input.is_action_just_pressed("set_bomb"):
		colocar_bomba()

# 💣 Método que coloca a bomba
func colocar_bomba():
	var bomba = bomba_escena.instance() # Cria uma instância da bomba
	get_parent().add_child(bomba) # Adiciona a bomba na cena
	bomba.global_transform.origin = global_transform.origin # Coloca a bomba na posição atual do jogador

# 💥 Método chamado quando o jogador é atingido
func exploded():
	print("O jogador foi destruído!") # Mensagem no console
	#queue_free() # Remove o jogador da cena
	respawn() # Chama o respawn após ser destruído

# 🔄 Método de respawn
func respawn():
	global_transform.origin = respawn_point.global_transform.origin # Teleporta o jogador ao ponto inicial
