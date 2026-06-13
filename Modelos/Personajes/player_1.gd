extends CharacterBody3D

# Variables de movimiento
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Referencia al AnimationTree y su máquina de estados
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")


# Función que se ejecuta al tocar un obstáculo peligroso
func reaparecer():
	# Reiniciamos la velocidad para que no conserve el impulso al aparecer
	velocity = Vector3.ZERO
	
	# Lo mandamos al punto inicial (0, 0, 0)
	global_position = Vector3(0, 0, 0)


func _physics_process(delta):
	# Agregar gravedad (si tu jugador es un CharacterBody3D)
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Obtener input del teclado
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# Lógica de animaciones: Si se mueve, usa "walk"
		state_machine.travel("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		# Lógica de animaciones: Si no se mueve, usa "Idle"
		state_machine.travel("Idle")

	move_and_slide()
