extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002
var camara_pos_original : Vector3


# --- NUEVAS VARIABLES PARA MEJORAR LA CÁMARA ---
const BOB_FREQ = 2.4      # Qué tan rápido oscila la cabeza al caminar
const BOB_AMP = 0.06      # Qué tan marcado es el sube y baja (sutil es mejor)
var t_bob = 0.0


# Variables para suavizar el movimiento del mouse
var rot_y = 0.0
var rot_x = 0.0
# -----------------------------------------------

@onready var brazo_camara = $Perspectiva
@onready var raycast = $Perspectiva/RayCastInteraccion

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Inicializamos las rotaciones con las actuales del nodo
	rot_y = rotation.y
	rot_x = brazo_camara.rotation.x
	camara_pos_original = brazo_camara.get_child(0).position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# En lugar de rotar de golpe, acumulamos los valores del mouse
		rot_y -= event.relative.x * MOUSE_SENSITIVITY
		rot_x -= event.relative.y * MOUSE_SENSITIVITY
		rot_x = clamp(rot_x, deg_to_rad(-50), deg_to_rad(50))

func _physics_process(delta: float) -> void:
	
	
	# 2. EFECTO HEAD BOBBING (Vaivén de cabeza con altura corregida)
	# 2. EFECTO HEAD BOBBING (Sumando el vaivén a la posición original del editor)
	if is_on_floor() and velocity.length() > 0.1:
		t_bob += delta * velocity.length() * float(is_on_floor())
		var pos_y = sin(t_bob * BOB_FREQ) * BOB_AMP
		var pos_x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP * 0.5
		
		# Sumamos el vaivén a las coordenadas originales
		brazo_camara.get_child(0).position.y = camara_pos_original.y + pos_y
		brazo_camara.get_child(0).position.x = camara_pos_original.x + pos_x
	else:
		# Si se detiene, regresa suavemente a la posición inicial exacta del editor
		t_bob = 0.0
		brazo_camara.get_child(0).position.y = lerp(brazo_camara.get_child(0).position.y, camara_pos_original.y, 10.0 * delta)
		brazo_camara.get_child(0).position.x = lerp(brazo_camara.get_child(0).position.x, camara_pos_original.x, 10.0 * delta)
	
	
	# 1. SUAVIZADO DE CÁMARA (Lerp)
	# Hace que la cámara persiga el movimiento del mouse con un retraso cinemático suave
	rotation.y = lerp_angle(rotation.y, rot_y, 10.0 * delta)
	brazo_camara.rotation.x = lerp(brazo_camara.rotation.x, rot_x, 10.0 * delta)

	# Gravedad base
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Salto
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimiento de entrada
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# 2. EFFECTO HEAD BOBBING (Vaivén de cabeza)
	if is_on_floor() and velocity.length() > 0.1:
		t_bob += delta * velocity.length() * float(is_on_floor())
		# Calculamos la onda seno para el eje Y (sube y baja)
		var pos_y = sin(t_bob * BOB_FREQ) * BOB_AMP
		# Calculamos una onda coseno más pequeña para el eje X (bamboleo lateral)
		var pos_x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP * 0.5
		
		# Aplicamos el movimiento a la cámara dentro del brazo
		brazo_camara.get_child(0).position.y = pos_y
		brazo_camara.get_child(0).position.x = pos_x
	else:
		# Si está quieto, la cámara regresa suavemente a su centro
		t_bob = 0.0
		brazo_camara.get_child(0).position.y = lerp(brazo_camara.get_child(0).position.y, 0.0, 10.0 * delta)
		brazo_camara.get_child(0).position.x = lerp(brazo_camara.get_child(0).position.x, 0.0, 10.0 * delta)
		
		
		
func _input(event):
	# Si presionas la tecla 'E'
	if Input.is_action_just_pressed("ui_accept"): # O puedes poner "interactuar" si ya creaste esa acción
		if raycast.is_colliding():
			var objeto = raycast.get_collider()
			# Si el objeto tiene la función 'presionar', la ejecutamos
			if objeto.has_method("presionar"):
				objeto.presionar()
