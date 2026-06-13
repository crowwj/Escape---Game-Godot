extends CharacterBody3D

# --- CONFIGURACIÓN DE MOVIMIENTO ---
const SPEED = 8.0
const JUMP_VELOCITY = 6.5

# --- CONFIGURACIÓN DE CÁMARA (MOUSE) ---
@export var MOUSE_SENSITIVITY: float = 0.15
@export var CAMERA_DELAY: float = 12.0  # Menor número = más delay/suavidad; Mayor número = más rápido

var rotation_target_x: float = 0.0
var rotation_target_y: float = 0.0

# Obtener la gravedad desde la configuración del proyecto para que use las físicas de Godot
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# --- REFERENCIAS A TUS NODOS ---
	# El Node3D intermedio
@onready var node_3d: CharacterBody3D = $"."
@onready var cuerpo_camara: Node3D = $CuerpoCamara


func _ready():
	# Bloquea y oculta el puntero del mouse al iniciar el juego para poder girar la vista
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Sincroniza la rotación inicial
	rotation_target_y = rotation.y
	rotation_target_x = cuerpo_camara.rotation.x

func _unhandled_input(event):
	
	if Input.is_action_just_pressed("reiniciar"):
		reaparecer()
	# Detectar el movimiento del mouse
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Almacenar a dónde queremos mirar según el arrastre del mouse
		rotation_target_y -= deg_to_rad(event.relative.x * MOUSE_SENSITIVITY)
		rotation_target_x -= deg_to_rad(event.relative.y * MOUSE_SENSITIVITY)
		
		# Limitar la vista hacia arriba y abajo para no romperte el cuello (85 grados máximo)
		rotation_target_x = clamp(rotation_target_x, deg_to_rad(-85), deg_to_rad(85))

func _physics_process(delta):
	# 1. Aplicar Gravedad si está en el aire
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. Manejar el Salto (Barra espaciadora o Flecha arriba / lo que tengas en ui_accept)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Obtener el vector de movimiento (Soporta WASD y Flechas por defecto en Godot)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Procesar el movimiento físico y las colisiones con el suelo
	move_and_slide()

	# 4. Aplicar el retraso suave de la cámara (Interpolación Lerp)
	rotation.y = lerp_angle(rotation.y, rotation_target_y, CAMERA_DELAY * delta)
	cuerpo_camara.rotation.x = lerp_angle(cuerpo_camara.rotation.x, rotation_target_x, CAMERA_DELAY * delta)



func reaparecer():
	# Frenamos en seco cualquier impulso que traiga el jugador
	velocity = Vector3.ZERO
	
	# Teletransportamos al jugador al origen del mapa (0, 0, 0)
	global_position = Vector3(0, 3.0, 0)
	
	# Reiniciamos la vista para que mire hacia el frente al revivir
	rotation_target_y = 0.0
	rotation_target_x = 0.0
	rotation.y = 0.0
	cuerpo_camara.rotation.x = 0.0
	
# Función que se activa al completar el nivel
func ganar_juego():
	# 1. Muestra una ventana emergente nativa del sistema operativo
	# Parámetros: OS.alert("Mensaje en el cuerpo", "Título de la ventana")
	OS.alert("¡Felicidades, lograste salir con vida!", "Escapaste")
	
	# 2. Cierra el juego por completo de inmediato en cuanto el jugador le dé a "Aceptar"
	get_tree().quit()
