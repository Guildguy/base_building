extends CharacterBody3D

var can_move := true
# Velocidade no plano
@export var speed: float = 5.0
# Intensidade da gravidade
@export var gravity: float = 9.8
# Força do pulo
@export var jump_force: float = 4.5

@onready var inventory_popup = $InventoryPopup

func _ready():
	add_to_group("player")
	inventory_popup.hide()

func _input(_event):
	if Input.is_action_just_pressed("inventory"): # mapeie "inventory" pra tecla I no Input Map
		if inventory_popup.visible:
			inventory_popup.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			inventory_popup.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _physics_process(delta: float) -> void:
	
	# Direção do movimento
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var direction := Vector3.ZERO

	# Pega a câmera 3d ativa para movimento relativo à visão
	var camera := get_viewport().get_camera_3d()

	if camera and input_dir.length() > 0:
		# Pega o transform (posição e direção) da câmera
		var cam_transform := camera.global_transform

		var cam_right := cam_transform.basis.x
		var cam_forward := -cam_transform.basis.z
		cam_right.y = 0
		cam_forward.y = 0

		# Normaliza vetores
		cam_right = cam_right.normalized()
		cam_forward = cam_forward.normalized()

		# Combina input do jogador com direção da câmera
		direction = (cam_right * input_dir.x) + (cam_forward * -input_dir.y)

		# Normaliza o vetor final para evitar que diagonais fiquem mais rápidas
		direction = direction.normalized()
		
		if not can_move:
			return

	# Gravidade
	# Se está no chão e tem velocidade pra cima, zera o Y
	if is_on_floor() and velocity.y > 0:
		velocity.y = 0
	else:
		# Aplica gravidade continuamente
		velocity.y -= gravity * delta

	# Pulo
	# Se está no chão e apertou o 'espaço' pra pular
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_force

	# Movimento horizontal
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()

func disable_movement(state: bool):
	can_move = not state

func open_trade_popup(chest):
	var trade = $InventoryTradePopup
	trade.open_trade(self, chest)


func _handle_inventory_input():
	if Input.is_action_just_pressed("inventory"):
		if inventory_popup.visible:
			inventory_popup.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			inventory_popup.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
