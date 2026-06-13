extends AnimatableBody3D

# --- CONFIGURACIÓN DESDE EL INSPECTOR ---
@export var direccion_movimiento: Vector3 = Vector3(0, 0, 35.0) # Dirección y distancia máxima
@export var velocidad: float = 4.0                            # Qué tan rápido avanza

var posicion_inicial: Vector3
var posicion_destino: Vector3
var hacia_el_destino: bool = true

func _ready():
	# Guarda el punto exacto donde dejaste la plataforma en tu mapa
	posicion_inicial = global_position
	# Calcula el punto final sumando la dirección
	posicion_destino = posicion_inicial + direccion_movimiento

func _physics_process(delta):
	# Decidimos a qué punto nos dirigimos
	var objetivo = posicion_destino if hacia_el_destino else posicion_inicial
	
	# Movemos la plataforma de manera fluida usando físicas
	global_position = global_position.move_toward(objetivo, velocidad * delta)
	
	# Si llega al destino, cambia de dirección para regresar
	if global_position.distance_to(objetivo) < 0.05:
		hacia_el_destino = not hacia_el_destino
