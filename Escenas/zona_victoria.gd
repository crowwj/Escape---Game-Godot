extends Area3D

func _ready():
	# Conectamos la señal para detectar cuándo entra un cuerpo a la zona
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Si lo que tocó la zona es nuestro jugador y tiene la función ganar_juego
	if body.has_method("ganar_juego"):
		body.ganar_juego()
